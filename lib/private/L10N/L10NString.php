<?php

/**
 * SPDX-FileCopyrightText: 2016-2024 Nextcloud GmbH and Nextcloud contributors
 * SPDX-FileCopyrightText: 2016 ownCloud, Inc.
 * SPDX-License-Identifier: AGPL-3.0-only
 */
namespace OC\L10N;

use BackedEnum;

class L10NString implements \JsonSerializable {
	/** @var L10N */
	protected $l10n;

	/** @var string */
	protected $text;

	/** @var array */
	protected $parameters;

	/** @var integer */
	protected $count;

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

		return vsprintf($text, array_map(fn(mixed $arg) => ($arg instanceof BackedEnum) ? $arg->value : $arg, $this->parameters));
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
