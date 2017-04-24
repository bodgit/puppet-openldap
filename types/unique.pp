# @since 2.0.0
type OpenLDAP::Unique = Struct[{Optional['strict'] => Boolean, Optional['ignore'] => Boolean, NotUndef['uri'] => Array[OpenLDAP::Unique::URI, 1]}]
