get_jwt <- function(access_token) {
  key_df <- get_jwk()
  jwk_key <- jose::read_jwk(key_df)
  jose::jwt_decode_sig(access_token, jwk_key)
}

get_jwk <- function() {
  httr::GET("https://pf-analytics.auth0.com/.well-known/jwks.json") %>%
    httr::content("text") %>%
    jsonlite::fromJSON() %>%
    extract2("keys")
}
