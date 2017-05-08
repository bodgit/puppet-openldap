# @since 2.0.0
type OpenLDAP::Access::By = Struct[{NotUndef['who'] => Array[OpenLDAP::Access::By::Who, 1], Optional['access'] => OpenLDAP::Access::By::Access, Optional['control'] => Enum['stop', 'continue', 'break']}]
