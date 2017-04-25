# @since 2.0.0
type OpenLDAP::Limit::Time = Variant[OpenLDAP::Limit::Generic, Struct[{Optional['soft'] => OpenLDAP::Limit::Generic, Optional['hard'] => Variant[OpenLDAP::Limit::Generic, Enum['soft']]}]]
