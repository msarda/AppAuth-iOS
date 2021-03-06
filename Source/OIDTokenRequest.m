/*! @file OIDTokenRequest.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2015 Google Inc. All Rights Reserved.
    @copydetails
        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
 */

#import "OIDTokenRequest.h"

#import "OIDDefines.h"
#import "OIDScopeUtilities.h"
#import "OIDServiceConfiguration.h"
#import "OIDURLQueryComponent.h"

/*! @var kConfigurationKey
    @brief The key for the @c configuration property for @c NSSecureCoding
 */
static NSString *const kConfigurationKey = @"configuration";

/*! @var kGrantTypeKey
    @brief Key used to encode the @c grantType property for @c NSSecureCoding
 */
static NSString *const kGrantTypeKey = @"grant_type";

/*! @var kAuthorizationCodeKey
    @brief The key for the @c authorizationCode property for @c NSSecureCoding.
 */
static NSString *const kAuthorizationCodeKey = @"code";

/*! @var kClientIDKey
    @brief Key used to encode the @c clientID property for @c NSSecureCoding
 */
static NSString *const kClientIDKey = @"client_id";

/*! @var kClientSecretKey
    @brief Key used to encode the @c clientSecret property for @c NSSecureCoding
 */
static NSString *const kClientSecretKey = @"client_secret";

/*! @var kRedirectURLKey
    @brief Key used to encode the @c redirectURL property for @c NSSecureCoding
 */
static NSString *const kRedirectURLKey = @"redirect_uri";

/*! @var kScopeKey
    @brief Key used to encode the @c scopes property for @c NSSecureCoding
 */
static NSString *const kScopeKey = @"scope";

/*! @var kRefreshTokenKey
    @brief Key used to encode the @c refreshToken property for @c NSSecureCoding
 */
static NSString *const kRefreshTokenKey = @"refresh_token";

/*! @var kCodeVerifierKey
    @brief Key used to encode the @c codeVerifier property for @c NSSecureCoding and to build the
        request URL.
 */
static NSString *const kCodeVerifierKey = @"code_verifier";

/*! @var kAdditionalParametersKey
    @brief Key used to encode the @c additionalParameters property for
        @c NSSecureCoding
 */
static NSString *const kAdditionalParametersKey = @"additionalParameters";

@implementation OIDTokenRequest

- (instancetype)init
    OID_UNAVAILABLE_USE_INITIALIZER(
        @selector(initWithConfiguration:
                              grantType:
                      authorizationCode:
                            redirectURL:
                               clientID:
                                  scope:
                           refreshToken:
                           codeVerifier:
                   additionalParameters:)
    );

- (nullable instancetype)initWithConfiguration:(OIDServiceConfiguration *)configuration
               grantType:(NSString *)grantType
       authorizationCode:(nullable NSString *)code
             redirectURL:(NSURL *)redirectURL
                clientID:(NSString *)clientID
            clientSecret:(nullable NSString *)clientSecret
                  scopes:(nullable NSArray<NSString *> *)scopes
            refreshToken:(nullable NSString *)refreshToken
            codeVerifier:(nullable NSString *)codeVerifier
    additionalParameters:(nullable NSDictionary<NSString *, NSString *> *)additionalParameters {
  return [self initWithConfiguration:configuration
                           grantType:grantType
                   authorizationCode:code
                         redirectURL:redirectURL
                            clientID:clientID
                        clientSecret:clientSecret
                               scope:[OIDScopeUtilities scopesWithArray:scopes]
                        refreshToken:refreshToken
                        codeVerifier:(NSString *)codeVerifier
                additionalParameters:additionalParameters];
}

- (nullable instancetype)initWithConfiguration:(OIDServiceConfiguration *)configuration
               grantType:(NSString *)grantType
       authorizationCode:(nullable NSString *)code
             redirectURL:(NSURL *)redirectURL
                clientID:(NSString *)clientID
            clientSecret:(nullable NSString *)clientSecret
                   scope:(nullable NSString *)scope
            refreshToken:(nullable NSString *)refreshToken
            codeVerifier:(nullable NSString *)codeVerifier
    additionalParameters:(nullable NSDictionary<NSString *, NSString *> *)additionalParameters {
  self = [super init];
  if (self) {
    _configuration = [configuration copy];
    _grantType = [grantType copy];
    _authorizationCode = [code copy];
    _redirectURL = [redirectURL copy];
    _clientID = [clientID copy];
    _clientSecret = [clientSecret copy];
    _scope = [scope copy];
    _refreshToken = [refreshToken copy];
    _codeVerifier = [codeVerifier copy];
    _additionalParameters =
        [[NSDictionary alloc] initWithDictionary:additionalParameters copyItems:YES];
  }
  return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(nullable NSZone *)zone {
  // The documentation for NSCopying specifically advises us to return a reference to the original
  // instance in the case where instances are immutable (as ours is):
  // "Implement NSCopying by retaining the original instead of creating a new copy when the class
  // and its contents are immutable."
  return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  OIDServiceConfiguration *configuration =
      [aDecoder decodeObjectOfClass:[OIDServiceConfiguration class]
                             forKey:kConfigurationKey];
  NSString *grantType = [aDecoder decodeObjectOfClass:[NSString class] forKey:kGrantTypeKey];
  NSString *code = [aDecoder decodeObjectOfClass:[NSString class] forKey:kAuthorizationCodeKey];
  NSString *clientID = [aDecoder decodeObjectOfClass:[NSString class] forKey:kClientIDKey];
  NSString *clientSecret = [aDecoder decodeObjectOfClass:[NSString class] forKey:kClientSecretKey];
  NSString *scope = [aDecoder decodeObjectOfClass:[NSString class] forKey:kScopeKey];
  NSString *refreshToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:kRefreshTokenKey];
  NSString *codeVerifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:kCodeVerifierKey];
  NSURL *redirectURL = [aDecoder decodeObjectOfClass:[NSURL class] forKey:kRedirectURLKey];
  NSSet *additionalParameterCodingClasses = [NSSet setWithArray:@[
    [NSDictionary class],
    [NSString class]
  ]];
  NSDictionary *additionalParameters =
      [aDecoder decodeObjectOfClasses:additionalParameterCodingClasses
                               forKey:kAdditionalParametersKey];
  self = [self initWithConfiguration:configuration
                           grantType:grantType
                   authorizationCode:code
                         redirectURL:redirectURL
                            clientID:clientID
                        clientSecret:clientSecret
                               scope:scope
                        refreshToken:refreshToken
                        codeVerifier:codeVerifier
                additionalParameters:additionalParameters];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_configuration forKey:kConfigurationKey];
  [aCoder encodeObject:_grantType forKey:kGrantTypeKey];
  [aCoder encodeObject:_authorizationCode forKey:kAuthorizationCodeKey];
  [aCoder encodeObject:_clientID forKey:kClientIDKey];
  [aCoder encodeObject:_clientSecret forKey:kClientSecretKey];
  [aCoder encodeObject:_redirectURL forKey:kRedirectURLKey];
  [aCoder encodeObject:_scope forKey:kScopeKey];
  [aCoder encodeObject:_refreshToken forKey:kRefreshTokenKey];
  [aCoder encodeObject:_codeVerifier forKey:kCodeVerifierKey];
  [aCoder encodeObject:_additionalParameters forKey:kAdditionalParametersKey];
}

#pragma mark - NSObject overrides

- (NSString *)description {
  NSURLRequest *request = self.URLRequest;
  NSString *requestBody =
      [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
  return [NSString stringWithFormat:@"<%@: %p, request: <URL: %@, HTTPBody: %@>>",
                                    NSStringFromClass([self class]),
                                    self,
                                    request.URL,
                                    requestBody];
}

#pragma mark -

/*! @fn tokenRequestURL
    @brief Constructs the request URI.
    @return A URL representing the token request.
    @see https://tools.ietf.org/html/rfc6749#section-4.1.3
 */
- (NSURL *)tokenRequestURL {
  return _configuration.tokenEndpoint;
}

/*! @fn tokenRequestBody
    @brief Constructs the request body data by combining the request parameters using the
        "application/x-www-form-urlencoded" format.
    @return The data to pass to the token request URL.
    @see https://tools.ietf.org/html/rfc6749#section-4.1.3
 */
- (NSData *)tokenRequestBody {
  OIDURLQueryComponent *query = [[OIDURLQueryComponent alloc] init];

  // Add parameters, as applicable.
  if (_grantType) {
    [query addParameter:kGrantTypeKey value:_grantType];
  }
  if (_scope) {
    [query addParameter:kScopeKey value:_scope];
  }
  if (_clientID) {
    [query addParameter:kClientIDKey value:_clientID];
  }
  if (_clientSecret && [_grantType isEqualToString:OIDGrantTypeAuthorizationCode]) {
    [query addParameter:kClientSecretKey value:_clientSecret];
  }
  if (_redirectURL) {
    [query addParameter:kRedirectURLKey value:_redirectURL.absoluteString];
  }
  if (_refreshToken) {
    [query addParameter:kRefreshTokenKey value:_refreshToken];
  }
  if (_authorizationCode) {
    [query addParameter:kAuthorizationCodeKey value:_authorizationCode];
  }
  if (_codeVerifier) {
    [query addParameter:kCodeVerifierKey value:_codeVerifier];
  }

  // Add any additional parameters the client has specified.
  [query addParameters:_additionalParameters];

  // Construct the body string:
  NSString *bodyString = [query URLEncodedParameters];
  NSData *body = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
  return body;
}

- (NSURLRequest *)URLRequest {
  static NSString *const kHTTPPost = @"POST";
  static NSString *const kHTTPContentTypeHeaderKey = @"Content-Type";
  static NSString *const kHTTPContentTypeHeaderValue =
      @"application/x-www-form-urlencoded; charset=UTF-8";

  NSURL *tokenRequestURL = [self tokenRequestURL];
  NSMutableURLRequest *URLRequest = [[NSURLRequest requestWithURL:tokenRequestURL] mutableCopy];
  URLRequest.HTTPMethod = kHTTPPost;
  [URLRequest setValue:kHTTPContentTypeHeaderValue forHTTPHeaderField:kHTTPContentTypeHeaderKey];
  URLRequest.HTTPBody = [self tokenRequestBody];
  return URLRequest;
}

@end
