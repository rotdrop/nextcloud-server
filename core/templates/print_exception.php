<?php
/**
 * SPDX-FileCopyrightText: 2016-2024 Nextcloud GmbH and Nextcloud contributors
 * SPDX-FileCopyrightText: 2012-2015 ownCloud, Inc.
 * SPDX-License-Identifier: AGPL-3.0-only
 */

function print_exception(Throwable $e, \OCP\IL10N $l): void {
	print_unescaped('<pre class="trace">');
	p($e->getTraceAsString());
	print_unescaped('</pre>');

	$e = $e->getPrevious();
	if ($e !== null) {
		print_unescaped('<div class="previous">');
		print_unescaped('<h3 class="previous">');
		p($l->t('Previous'));
		print_unescaped('</h3>');
		print_unescaped('       <ul class="technical">');
		print_unescaped('               <li class="class">');
		p($l->t('Type: %s', get_class($e)));
		print_unescaped('               </li>');
		print_unescaped('               <li class="code">');
		p($l->t('Code: %s', $e->getCode()));
		print_unescaped('               </li>');
		print_unescaped('               <li class="message">');
		p($l->t('Message: %s', $e->getMessage()));
		print_unescaped('               </li>');
		print_unescaped('               <li class="file">');
		p($l->t('File: %s', $e->getFile()));
		print_unescaped('               </li>');
		print_unescaped('               <li class="line">');
		p($l->t('Line: %s', $e->getLine()));
		print_unescaped('               </li>');
		print_unescaped('       </ul>');
		print_unescaped('   <h3 class="trace">');
		p($l->t('Trace'));
		print_unescaped('       </h3>');
		print_exception($e, $l);
		print_unescaped('</div>'); // close previous
	}
}
