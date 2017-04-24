# @since 2.0.0
type OpenLDAP::Unique::URI = Pattern[/(?x) ^ ldap:\/\/\/ [^?]* \? [^?]* \? (?: sub | one ) (?: \? (?: \( .+ \) )? )? $/]
