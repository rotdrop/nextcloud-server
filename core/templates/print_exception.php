<?php
/**
 * SPDX-FileCopyrightText: 2016-2024 Nextcloud GmbH and Nextcloud contributors
 * SPDX-FileCopyrightText: 2012-2015 ownCloud, Inc.
 * SPDX-License-Identifier: AGPL-3.0-only
 */

function print_exception(Throwable $e, \OCP\IL10N $l): void {
	print_unescaped('<pre>');
	p($e->getTraceAsString());
	print_unescaped('</pre>');

	$e = $e->getPrevious();
	if ($e !== null) {
		print_unescaped('<br />');
		print_unescaped('<h4>');
		p($l->t('Previous'));
	    print_unescaped('</h4>');

		print_unescaped('<ul>');
		print_unescaped('<li>');
		p($l->t('Code: %s', $e->getCode()));
		print_unescaped('</li>');
		print_unescaped('<li>');
		p($l->t('Message: %s', $e->getMessage()));
		print_unescaped('</li>');
		print_unescaped('<li>');
		p($l->t('File: %s', $e->getFile()));
		print_unescaped('</li>');
		print_unescaped('<li>');
		p($l->t('Line: %s', $e->getLine()));
		print_unescaped('</li>');
		print_unescaped('</ul>');
		print_exception($e, $l);
	}
}
