# @since 2.0.0
type OpenLDAP::SizeLimit = Variant[OpenLDAP::GenericLimit, Struct[{Optional['soft'] => OpenLDAP::GenericLimit, Optional['hard'] => Variant[OpenLDAP::GenericLimit, Enum['soft']], Optional['unchecked'] => Variant[OpenLDAP::GenericLimit, Enum['disable']]}]]
