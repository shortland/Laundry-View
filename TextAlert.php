<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$sendIt = false;

if($sendIt) {
	$to      = '6464643484@tmomail.net';
	$subject = 'Subject Here';
	$message = 'Test message blah bla';
	$headers = 'From: CoinAlert@mywebsite.com' . "\r\n" .
	    'Reply-To: myemail@tmomail.net' . "\r\n" .
	    'X-Mailer: PHP/' . phpversion();

	mail($to, $subject, $message, $headers);
	echo "Sent successfully<br/>\n";
}
else {
	echo "Mail not sent<br/>\n";
}

echo "Complete.";
?>