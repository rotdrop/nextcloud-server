<?php

declare(strict_types=1);

/**
 * @copyright Copyright (c) 2020, Claus-Justus Heine <himself@claus-justus-heine.de>
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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

namespace OC\L10N\Events;

use OCP\EventDispatcher\Event;

class TranslationNotFound extends Event {

	/** @var string */
	private $phrase;

	/** @var string */
	private $language;

	/** @var string */
	private $locale;

	/** @var string */
	private $app;

	/** @var array */
	private $callerFrame;

	public function __construct(string $phrase, string $language, string $locale = null, string $app = null, int $frame = 4) {
		parent::__construct();

		$this->phrase = $phrase;
		$this->language = $language;
		$this->locale = $locale;
		$this->app = $app;

		// normally called from l10n object, so level 4 should
		// be the calling stack-frame.
		$this->callerFrame = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, $frame)[$frame-1];
	}

	public function getPhrase(): string {
		return $this->phrase;
	}

	public function getLanguage(): string {
		return $this->language;
	}
	
	public function getLocale(): string {
		return $this->locale;
	}
	
	public function getAppName(): string {
		return $this->app;
	}

	public function getCallerFrame(): array {
		return $this->callerFrame;
	}

	public function getFile(): string {
		if (!empty($this->callerFrame['file'])) {
			return $this->callerFrame['file'];
		}
		return '';
	}

	public function getLine(): int {
		if (!empty($this->callerFrame['line'])) {
			return $this->callerFrame['line'];
		}
		return -1;
	}
}

/*
 * Local Variables: ***
 * c-basic-offset: 8 ***
 * tab-width: 8 ***
 * indent-tabs-mode: t ***
 * End: ***
 */
