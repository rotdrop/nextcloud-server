<?php

/**
 * SPDX-FileCopyrightText: 2016-2025 Nextcloud GmbH and Nextcloud contributors
 * SPDX-FileCopyrightText: 2016 ownCloud, Inc.
 * SPDX-License-Identifier: AGPL-3.0-only
 */
namespace OC\Files\Config;

use OC\Files\Filesystem;
use OCP\Files\Config\ICachedMountInfo;
use OCP\Files\Node;
use OCP\IUser;

class CachedMountInfo implements ICachedMountInfo {
	protected IUser $user;
	protected int $storageId;
	protected int $rootId;
	protected string $mountPoint;
	protected ?int $mountId;
	protected string $rootInternalPath;
	protected string $mountProvider;
	protected string $key;

	/**
	 * @var bool
	 */
	protected $enableSharing;

	/**
	 * @var bool
	 */
	protected $authenticated;

	/**
	 * CachedMountInfo constructor.
	 *
	 * @param IUser $user
	 * @param int $storageId
	 * @param int $rootId
	 * @param string $mountPoint
	 * @param int|null $mountId
	 * @param string $rootInternalPath
	 */
	public function __construct(
		IUser $user,
		int $storageId,
		int $rootId,
		string $mountPoint,
		string $mountProvider,
		?int $mountId = null,
		string $rootInternalPath = '',
		bool $enableSharing = true,
		bool $authenticated = false
	) {
		$this->user = $user;
		$this->storageId = $storageId;
		$this->rootId = $rootId;
		$this->mountPoint = $mountPoint;
		$this->mountId = $mountId;
		$this->rootInternalPath = $rootInternalPath;
		if (strlen($mountProvider) > 128) {
			throw new \Exception("Mount provider $mountProvider name exceeds the limit of 128 characters");
		}
		$this->mountProvider = $mountProvider;
		$this->key = $rootId . '::' . $mountPoint;
		$this->enableSharing = $enableSharing;
		$this->authenticated = $authenticated;
	}

	/**
	 * @return IUser
	 */
	public function getUser(): IUser {
		return $this->user;
	}

	/**
	 * @return int the numeric storage id of the mount
	 */
	public function getStorageId(): int {
		return $this->storageId;
	}

	/**
	 * @return int the fileid of the root of the mount
	 */
	public function getRootId(): int {
		return $this->rootId;
	}

	/**
	 * @return Node|null the root node of the mount
	 */
	public function getMountPointNode(): ?Node {
		// TODO injection etc
		Filesystem::initMountPoints($this->getUser()->getUID());
		$userNode = \OC::$server->getUserFolder($this->getUser()->getUID());
		return $userNode->getParent()->getFirstNodeById($this->getRootId());
	}

	/**
	 * @return string the mount point of the mount for the user
	 */
	public function getMountPoint(): string {
		return $this->mountPoint;
	}

	/**
	 * Get the id of the configured mount
	 *
	 * @return int|null mount id or null if not applicable
	 * @since 9.1.0
	 */
	public function getMountId(): ?int {
		return $this->mountId;
	}

	/**
	 * Get the internal path (within the storage) of the root of the mount
	 *
	 * @return string
	 */
	public function getRootInternalPath(): string {
		return $this->rootInternalPath;
	}

	public function getMountProvider(): string {
		return $this->mountProvider;
	}

	public function getKey(): string {
		return $this->key;
	}

	/**
	 * Whether this mount point can be shared with others
	 *
	 * @return bool
	 * @since 24.0.0
	 */
	public function getEnableSharing(): bool {
		return (bool)$this->enableSharing;
	}

	/**
	 * Whether this mount point needs authentication
	 *
	 * @return bool
	 * @since 24.0.0
	 */
	public function getAuthenticated(): bool {
		return (bool)$this->authenticated;
	}
}
