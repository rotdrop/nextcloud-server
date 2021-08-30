<?php
/**
 * @copyright Copyright (c) 2016, ownCloud, Inc.
 *
 * @author Bart Visscher <bartv@thisnet.nl>
 * @author Bernhard Posselt <dev@bernhard-posselt.com>
 * @author Jakob Sack <mail@jakobsack.de>
 * @author Joas Schilling <coding@schilljs.com>
 * @author Jörn Friedrich Dreyer <jfd@butonic.de>
 * @author Roeland Jago Douma <roeland@famdouma.nl>
 * @author Thomas Müller <thomas.mueller@tmit.eu>
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
namespace OC\L10N;

use OCP\EventDispatcher\IEventDispatcher;
use OCP\ILogger;

class L10NString implements \JsonSerializable {
	/** @var L10N */
	protected $l10n;

	/** @var string */
	protected $text;

	/** @var array */
	protected $parameters;

	/** @var integer */
	protected $count;

	/** @var bool */
	static protected $eventLock = false;

	/**
	 * @param L10N $l10n
	 * @param string|string[] $text
	 * @param array $parameters
	 * @param int $count
	 */
	public function __construct(L10N $l10n, $text, array $parameters, int $count = 1) {
		$this->l10n = $l10n;
		$this->text = $text;
		$this->parameters = $parameters;
		$this->count = $count;
	}

	public function __toString(): string {
		$translations = $this->l10n->getTranslations();
		$identityTranslator = $this->l10n->getIdentityTranslator();

		// Use the indexed version as per \Symfony\Contracts\Translation\TranslatorInterface
		$identity = $this->text;
		if (array_key_exists($this->text, $translations)) {
			$identity = $translations[$this->text];
		} else if (!self::$eventLock) {
			self::$eventLock = true;
			$text = $this->text;
			$app = $this->l10n->getAppName();
			$language = $this->l10n->getLanguageCode();
			$locale = $this->l10n->getLocaleCode();
			$event = new Events\TranslationNotFound($text, $language, $locale, $app);
			\OC::$server->query(IEventDispatcher::class)->dispatchTyped($event);
			//\OCP\Util::writeLog($app, "Translation for ``".$text."'' not found.", ILogger::INFO);
			self::$eventLock = false;
		}

		if (!$this->pipeCheck($identity)) {
			return 'Can not use unescaped pipe character in translations, prepend another pipe character to escape a single pipe character';
		}

		if (is_array($identity)) {
			$identity = implode('|', $identity);
		}
		$beforeIdentity = $identity;
		$identity = str_replace('%n', '%count%', $identity);

		$parameters = [];
		if ($beforeIdentity !== $identity) {
			$parameters = ['%count%' => $this->count];
		}

		// $count as %count% as per \Symfony\Contracts\Translation\TranslatorInterface
		$text = $identityTranslator->trans($identity, $parameters);

		return vsprintf($text, $this->parameters);
	}

	public function jsonSerialize(): string {
		return $this->__toString();
	}

	/**
	 * @param string|array $identity
	 * @return bool
	 */
	private function pipeCheck($identity) {
		$pipeCheck = is_array($identity) ? implode('', $identity) : $identity;
		if (preg_match('/^\|++$/', $pipeCheck)) {
			$parts = explode('|', $pipeCheck);
		} elseif (preg_match_all('/(?:\|\||[^\|])++/', $pipeCheck, $matches)) {
			$parts = $matches[0];
		}
		return count($matches) <= 1;
	}
}
