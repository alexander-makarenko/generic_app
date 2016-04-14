INVALID_EMAILS = %w[
  .starts-with-dot@example.com
  double..dot@test.org
  double.dot@test..org
  no_at_sign.net
  double@at@sign.com
  without@dot,com
  ends+with@dot.
]

VALID_EMAILS = %w[
  user@foo-bar.baz.com
  user@example.com
  first.last@somewhere.COM
  fir5t_la5t@somewhe.re
  FIRST+LAST@s.omwhe.re
]