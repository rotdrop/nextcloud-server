<?php
/**
 * @copyright Copyright (c) 2023 Claus-Justus Heine
 *
 * @author Claus-Justus Heine <himself@claus-justus-heine.de>
 *
 * @license GNU AGPL version 3 or any later version
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */
namespace OCA\DAV\Connector\Sabre;

use Sabre\DAV\Server;
use Sabre\DAV\ServerPlugin;
use Sabre\HTTP\RequestInterface;
use Sabre\HTTP\ResponseInterface;

class QuirksPlugin extends ServerPlugin {

	/** @var bool */
	private $isMacOSDavAgent = false;

	/** @psalm-var null|array{major: string, minor: string, patch: string}  */
	private $macOSVersion = null;

	/** @var null|string */
	private $macOSAgent = null;

	/** @psalm-var null|array{major: string, minor: null|string, patch: null|string} */
	private $macOSAgentVersion = null;

	/**
     * Sets up the plugin.
     *
     * This method is automatically called by the server class.
	 *
	 * @return void
     */
    public function initialize(Server $server)
    {
		$server->on('beforeMethod:*', [$this, 'beforeMethod'], 0);
		$server->on('report', [$this, 'report'], 0);
	}

	/**
     * Triggered before any method is handled.
	 *
	 * @return void
     */
    public function beforeMethod(RequestInterface $request, ResponseInterface $response)
    {
		$userAgent = $request->getRawServerValue('HTTP_USER_AGENT') ?? 'unknown';

		// OSX agent string: macOS/13.2.1 (22D68) dataaccessd/1.0
		if (preg_match('|macOS/([0-9]+)\\.([0-9]+)\\.([0-9]+)\s+\((\w+)\)\s+([^/]+)/([0-9]+)(?:\\.([0-9]+))?(?:\\.([0-9]+))?$|i', $userAgent, $matches)) {
			$this->isMacOSDavAgent = true;
			$this->macOSVersion = [
				'major' => $matches[1],
				'minor' => $matches[2],
				'patch' => $matches[3],
			];
			$this->macOSAgent = $matches[5];
			$this->macOSAgentVersion = [
				'major' => $matches[6],
				'minor' => $matches[7] ?? null,
				'patch' => $matches[8] ?? null,
			];
			// \OCP\Util::writeLog('dav', 'OSX AGENT', \OCP\Util::INFO);
		}
	}

	/**
     * This method handles HTTP REPORT requests.
     *
     * @param string $reportName
     * @param mixed  $report
     * @param mixed  $path
	 *
	 * @return bool
     */
    public function report($reportName, $report, $path)
    {
		if ($this->isMacOSDavAgent && $reportName == '{DAV:}principal-property-search') {
			/** @var \Sabre\DAVACL\Xml\Request\PrincipalPropertySearchReport $report */
			$report->applyToPrincipalCollectionSet = true;
		}
		return true;
	}
}
