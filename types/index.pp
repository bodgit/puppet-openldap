# @since 2.0.0
type OpenLDAP::Index = Variant[Tuple[Array[Enum['default'], 1, 1], Array[OpenLDAP::Index::Type, 1]], Tuple[Array[Pattern[/(?x) ^ (?! default $ ) [[:alnum:]]+ $/], 1], Array[OpenLDAP::Index::Type, 1], 1]]
