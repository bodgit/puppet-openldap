# @since 2.0.0
type OpenLDAP::LogLevel = Variant[Integer[0, 65535], Enum['trace', 'packets', 'args', 'conns', 'BER', 'filter', 'config', 'ACL', 'stats', 'stats2', 'shell', 'parse', 'sync', 'none']]
