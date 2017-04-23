# @since 2.0.0
type OpenLDAP::TimeLimit = Variant[OpenLDAP::GenericLimit, Struct[{Optional['soft'] => OpenLDAP::GenericLimit, Optional['hard'] => Variant[OpenLDAP::GenericLimit, Enum['soft']]}]]
