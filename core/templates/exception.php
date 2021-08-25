<?php
/** @var array $_ */
/** @var \OCP\IL10N $l */

style('core', ['styles', 'header']);

function print_exception(Throwable $e, \OCP\IL10N $l): void {
	print_unescaped('<pre class="trace">');
	p($e->getTraceAsString());
	print_unescaped('</pre>');

	if ($e->getPrevious() !== null) {
		$e = $e->getPrevious();
		print_unescaped('<div class="previous">');
		print_unescaped('<h3 class="previous">');
		p($l->t('Previous'));
		print_unescaped('</h3>');
		print_unescaped('	<ul class="technical">');
		print_unescaped('		<li class="class">');
		p($l->t('Type: %s', get_class($e)));
		print_unescaped('		</li>');
		print_unescaped('		<li class="code">');
		p($l->t('Code: %s', $e->getCode()));
		print_unescaped('		</li>');
		print_unescaped('		<li class="message">');
		p($l->t('Message: %s', $e->getMessage()));
		print_unescaped('		</li>');
		print_unescaped('		<li class="file">');
		p($l->t('File: %s', $e->getFile()));
		print_unescaped('		</li>');
		print_unescaped('		<li class="line">');
		p($l->t('Line: %s', $e->getLine()));
		print_unescaped('		</li>');
		print_unescaped('	</ul>');
	    print_unescaped('	<h3 class="trace">');
		p($l->t('Trace'));
		print_unescaped('	</h3>');
		print_exception($e, $l);
		print_unescaped('</div>'); // close previous
	}
}

?>
<div class="guest-box wide exception">
	<h2><?php p($l->t('Internal Server Error')) ?></h2>
	<p><?php p($l->t('The server was unable to complete your request.')) ?></p>
	<p><?php p($l->t('If this happens again, please send the technical details below to the server administrator.')) ?></p>
	<p><?php p($l->t('More details can be found in the server log.')) ?></p>

	<h3 class="technical"><?php p($l->t('Technical details')) ?></h3>
	<ul class="technical">
		<li class="remote"><?php p($l->t('Remote Address: %s', [$_['remoteAddr']])) ?></li>
		<li class="request"><?php p($l->t('Request ID: %s', [$_['requestID']])) ?></li>
		<?php if (isset($_['debugMode']) && $_['debugMode'] === true): ?>
			<li class="class"><?php p($l->t('Type: %s', [$_['errorClass']])) ?></li>
			<li class="code"><?php p($l->t('Code: %s', [$_['errorCode']])) ?></li>
			<li class="message"><?php p($l->t('Message: %s', [$_['errorMsg']])) ?></li>
			<li class="file"><?php p($l->t('File: %s', [$_['file']])) ?></li>
			<li class="line"><?php p($l->t('Line: %s', [$_['line']])) ?></li>
		<?php endif; ?>
	</ul>

	<?php if (isset($_['debugMode']) && $_['debugMode'] === true): ?>
		<h3 class="trace"><?php p($l->t('Trace')) ?></h3>
		<?php print_exception($_['exception'], $l); ?>
	<?php endif; ?>
</div>
