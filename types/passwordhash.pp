# @since 2.0.0
type OpenLDAP::PasswordHash = Pattern[/(?x) ^ {(?:S?SHA(?:256|384|512)?|(?:S|BSD)?MD5|CRYPT|CLEARTEXT|TOTP(?:1|256|512)|PBKDF2(?:-SHA(?:1|256|512))?|RADIUS|NS-MTA-MD5|KERBEROS|APR1)} $/]
