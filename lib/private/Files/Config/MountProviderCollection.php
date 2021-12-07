<?php
/**
 * @copyright Copyright (c) 2016, ownCloud, Inc.
 *
 * @author Christoph Wurst <christoph@winzerhof-wurst.at>
 * @author Morris Jobke <hey@morrisjobke.de>
 * @author Robin Appelman <robin@icewind.nl>
 * @author Roeland Jago Douma <roeland@famdouma.nl>
 *
 * @license AGPL-3.0
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License, version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License, version 3,
 * along with this program. If not, see <http://www.gnu.org/licenses/>
 *
 */
namespace OC\Files\Config;

use OC\Hooks\Emitter;
use OC\Hooks\EmitterTrait;
use OCP\Diagnostics\IEventLogger;
use OCP\Files\Config\IHomeMountProvider;
use OCP\Files\Config\IMountProvider;
use OCP\Files\Config\IMountProviderCollection;
use OCP\Files\Config\IRootMountProvider;
use OCP\Files\Config\IUserMountCache;
use OCP\Files\Mount\IMountManager;
use OCP\Files\Mount\IMountPoint;
use OCP\Files\Storage\IStorageFactory;
use OCP\IUser;

class MountProviderCollection implements IMountProviderCollection, Emitter {
	use EmitterTrait;

	/**
	 * @var \OCP\Files\Config\IHomeMountProvider[]
	 */
	private $homeProviders = [];

	/**
	 * @var array<int, \OCP\Files\Config\IMountProvider[]>
	 */
	private $providers = [];

	/** @var \OCP\Files\Config\IRootMountProvider[] */
	private $rootProviders = [];

	/**
	 * @var \OCP\Files\Storage\IStorageFactory
	 */
	private $loader;

	/**
	 * @var \OCP\Files\Config\IUserMountCache
	 */
	private $mountCache;

	/** @var callable[] */
	private $mountFilters = [];

	private IEventLogger $eventLogger;

	/**
	 * @param \OCP\Files\Storage\IStorageFactory $loader
	 * @param IUserMountCache $mountCache
	 */
	public function __construct(
		IStorageFactory $loader,
		IUserMountCache $mountCache,
		IEventLogger $eventLogger
	) {
		$this->loader = $loader;
		$this->mountCache = $mountCache;
		$this->eventLogger = $eventLogger;
	}

	private function getMountsFromProvider(IMountProvider $provider, IUser $user, IStorageFactory $loader): array {
		$class = str_replace('\\', '_', get_class($provider));
		$uid = $user->getUID();
		$this->eventLogger->start('fs:setup:provider:' . $class, "Getting mounts from $class for $uid");
		$mounts = $provider->getMountsForUser($user, $loader) ?? [];
		$this->eventLogger->end('fs:setup:provider:' . $class);
		return $mounts;
	}

	/**
	 * @param IUser $user
	 * @param IMountProvider[] $providers
	 * @return IMountPoint[]
	 */
	private function getUserMountsForProviders(IUser $user, array $providers): array {
		$loader = $this->loader;
		$mounts = array_map(function (IMountProvider $provider) use ($user, $loader) {
			return $this->getMountsFromProvider($provider, $user, $loader);
		}, $providers);
		$mounts = array_filter($mounts, function ($result) {
			return is_array($result);
		});
		$mounts = array_reduce($mounts, function (array $mounts, array $providerMounts) {
			return array_merge($mounts, $providerMounts);
		}, []);
		return $this->filterMounts($user, $mounts);
	}

	public function getMountsForUser(IUser $user): array {
		return $this->getUserMountsForProviders($user, $this->getProviders());
	}

	public function getUserMountsForProviderClasses(IUser $user, array $mountProviderClasses): array {
		$providers = array_filter(
			$this->getProviders(),
			fn (IMountProvider $mountProvider) => (in_array(get_class($mountProvider), $mountProviderClasses))
		);
		return $this->getUserMountsForProviders($user, $providers);
	}

	public function addMountForUser(IUser $user, IMountManager $mountManager, callable $providerFilter = null) {
		// shared mount provider gets to go last since it needs to know existing files
		// to check for name collisions

		$priorizedMounts = [];
		foreach ($this->providers as $priority => $providers) {
			$priorityMounts = [];
			foreach ($providers as $provider) {
				$mounts = $provider->getMountsForUser($user, $this->loader);
				if (is_array($mounts)) {
					$priorityMounts = array_merge($priorityMounts, $mounts);
				}
			}
			$priorityMounts = $this->filterMounts($user, $priorityMounts);
			$this->eventLogger->start("fs:setup:add-mounts", "Add mounts to the filesystem");
			array_walk($priorityMounts, [$mountManager, 'addMount']);
			$this->eventLogger->end("fs:setup:add-mounts");
			$priorizedMounts[$priority] = $priorityMounts;
		}

		return array_merge(...$priorizedMounts);
	}

	/**
	 * Get the configured home mount for this user
	 *
	 * @param \OCP\IUser $user
	 * @return \OCP\Files\Mount\IMountPoint
	 * @since 9.1.0
	 */
	public function getHomeMountForUser(IUser $user) {
		/** @var \OCP\Files\Config\IHomeMountProvider[] $providers */
		$providers = array_reverse($this->homeProviders); // call the latest registered provider first to give apps an opportunity to overwrite builtin
		foreach ($providers as $homeProvider) {
			if ($mount = $homeProvider->getHomeMountForUser($user, $this->loader)) {
				$mount->setMountPoint('/' . $user->getUID()); //make sure the mountpoint is what we expect
				return $mount;
			}
		}
		throw new \Exception('No home storage configured for user ' . $user);
	}

	/**
	 * Add a provider for mount points
	 *
	 * @param \OCP\Files\Config\IMountProvider $provider
	 *
	 * @param int $priority
	 */
	public function registerProvider(IMountProvider $provider, int $priority = self::DEFAULT_PRIORITY) {
		if ($provider instanceof \OCA\Files_Sharing\MountProvider
			&& $priority === self::DEFAULT_PRIORITY) {
			$priority = self::SHARES_PRIORITY;
		}
		$this->providers[$priority][] = $provider;
		ksort($this->providers);

		$this->emit('\OC\Files\Config', 'registerMountProvider', [$provider]);
	}

	public function registerMountFilter(callable $filter) {
		$this->mountFilters[] = $filter;
	}

	private function filterMounts(IUser $user, array $mountPoints) {
		return array_filter($mountPoints, function (IMountPoint $mountPoint) use ($user) {
			foreach ($this->mountFilters as $filter) {
				if ($filter($mountPoint, $user) === false) {
					return false;
				}
			}
			return true;
		});
	}

	/**
	 * Add a provider for home mount points
	 *
	 * @param \OCP\Files\Config\IHomeMountProvider $provider
	 * @since 9.1.0
	 */
	public function registerHomeProvider(IHomeMountProvider $provider) {
		$this->homeProviders[] = $provider;
		$this->emit('\OC\Files\Config', 'registerHomeMountProvider', [$provider]);
	}

	/**
	 * Get the mount cache which can be used to search for mounts without setting up the filesystem
	 *
	 * @return IUserMountCache
	 */
	public function getMountCache() {
		return $this->mountCache;
	}

	public function registerRootProvider(IRootMountProvider $provider) {
		$this->rootProviders[] = $provider;
	}

	/**
	 * Get all root mountpoints
	 *
	 * @return \OCP\Files\Mount\IMountPoint[]
	 * @since 20.0.0
	 */
	public function getRootMounts(): array {
		$loader = $this->loader;
		$mounts = array_map(function (IRootMountProvider $provider) use ($loader) {
			return $provider->getRootMounts($loader);
		}, $this->rootProviders);
		$mounts = array_reduce($mounts, function (array $mounts, array $providerMounts) {
			return array_merge($mounts, $providerMounts);
		}, []);

		if (count($mounts) === 0) {
			throw new \Exception("No root mounts provided by any provider");
		}

		return $mounts;
	}

	public function clearProviders() {
		$this->providers = [];
		$this->homeProviders = [];
		$this->rootProviders = [];
	}

	public function getProviders(): array {
		return array_merge(...$this->providers);
	}
}
