# OAuth from the beginning — history, RFC timeline and reading path

> **Read this first.** This document tells the story of OAuth from its first
> discussion in November 2006 to October 2026, lists every RFC vendored in this
> repository on one timeline, and gives a staged reading path through the local
> copies. Research data was gathered on 10 October 2026; the local copies were
> refreshed and verified on 11 October 2026.
>
> Companion documents: [rfc-coverage-audit.md](rfc-coverage-audit.md) (how the
> spec covers each document) and the 724 verified findings in
> [rfc-coverage-findings/](rfc-coverage-findings/README.md).

## Contents

1. [How to use this document](#1-how-to-use-this-document)
2. [OAuth on one page](#2-oauth-on-one-page)
3. [The eras](#3-the-eras)
4. [Why each extension exists](#4-why-each-extension-exists)
5. [Roads not taken](#5-roads-not-taken)
6. [The complete RFC timeline](#6-the-complete-rfc-timeline)
7. [What comes next](#7-what-comes-next)
8. [Reading path](#8-reading-path)
9. [Key lessons](#9-key-lessons)
10. [Sources](#10-sources)

## 1. How to use this document

**Who it is for.** An engineer who wants to learn OAuth from its origins and then
build a security-first OAuth 2.1 authorization server. You should know HTTP
(Hypertext Transfer Protocol), TLS (Transport Layer Security) and basic
public-key cryptography. You do not need to know OAuth.

**Three parts.**

- **The story** (sections 2-5). One page of history, then eight eras with dated
  events, the reason behind each extension, and the approaches that were
  abandoned.
- **The timeline** (sections 6-7). Every RFC in
  [`../rfc-sources/`](../rfc-sources/) in publication order, the OAuth-related
  RFCs that live outside the HTTP authorization server, and the drafts that come
  next.
- **The reading path** (sections 8-9). A staged curriculum through the local
  copies, then the design lessons of twenty years.

**Everything in the reading path is local.** The main document of every step is
vendored in this repository: 50 RFCs plus the OAuth 2.1 draft in
[`../rfc-sources/`](../rfc-sources/) (list:
[`manifest.txt`](../rfc-sources/manifest.txt)) and 12 OpenID Foundation
documents in [`../oidf-sources/`](../oidf-sources/) (list:
[`manifest.txt`](../oidf-sources/manifest.txt)). Some steps add a short online
companion (a historical page, a paper or a draft); these are marked "online".
To refresh the local copies, or to check them against upstream, run
[`../../tools/fetch-specs.sh`](../../tools/fetch-specs.sh).

**Suggested use.** Read section 2 first (about ten minutes). Use section 3 when
you want the detail behind a date. Then follow section 8 in order. While you read
a document, open the matching part of the spec,
[`../../oauth-openapi.yaml`](../../oauth-openapi.yaml), and the findings file for
that document's cluster.

**Date format.** `2012-10-13` means an exact day. `2012-10` means only the month
is given (the RFC Editor index records month and year). Draft states are as of
10 October 2026.

**Terms and acronyms used throughout.** Other acronyms are defined where they
first appear.

| Term | Meaning |
|---|---|
| API | Application programming interface. |
| The YAML, the spec | [`../../oauth-openapi.yaml`](../../oauth-openapi.yaml): this repository's description of an OAuth authorization server in OpenAPI 3.1, a standard format for describing HTTP APIs. YAML is the text format of the file. |
| HTTP, HTTPS | Hypertext Transfer Protocol; HTTP over TLS. |
| XML, HTML | Extensible Markup Language; HyperText Markup Language, the format of web pages and of the vendored OIDF documents. |
| RSA, SHA-1, SHA-256 | The Rivest-Shamir-Adleman public-key algorithm; Secure Hash Algorithm versions. |
| AS | Authorization server: issues tokens after the resource owner approves. |
| RS | Resource server: the API that accepts access tokens. |
| Client | The application that wants access. A *public* client cannot keep a secret (a mobile app, a single-page application); a *confidential* client can (a server-side web app). |
| Resource owner | Usually the user. |
| Grant | A way for a client to obtain tokens: authorization code, client credentials, refresh token, device code, and others. |
| Access token, refresh token | The client sends an access token to the RS to use a protected resource. It sends a refresh token to the AS to get a new access token (RFC 6749 §1.4-§1.5). |
| Authorization code | A short-lived, one-time value. The AS sends it to the client through the browser, and the client exchanges it for tokens at the token endpoint. |
| Endpoint | An HTTP URL with one function. For example, the browser visits the authorization endpoint (`/authorize`), and the client calls the token endpoint (`/token`) directly. |
| Redirect URI | The client's address. The AS sends the browser back to it with the result (a code or an error). |
| Scope | A list of space-separated strings that names the access the client requests (RFC 6749 §3.3). |
| `state`, nonce | A nonce is a random value that is used only once, so that a message cannot be replayed. The client sends `state` in the authorization request and checks it in the response; this ties the response to the user's browser session (protection against CSRF). The OIDC `nonce` parameter ties an ID Token to the client's session in a similar way. |
| Assertion | A signed statement about a subject, such as a SAML (Security Assertion Markup Language) assertion or a JWT. One party issues it and another party checks it. OAuth uses assertions as grants and for client authentication (RFC 7521). |
| Bearer token | A token that works for anyone who holds it. |
| Sender-constrained token | A token bound to a key; the client must prove that it holds the key. |
| PoP | Proof of possession: proving that you hold a key. |
| Front channel / back channel | Messages carried by the user's browser through redirects / direct HTTPS calls between client and server. |
| IETF | Internet Engineering Task Force: the standards body that produces most RFCs. |
| RFC | Request for Comments: a numbered IETF document. Its text never changes after publication. |
| I-D, draft | Internet-Draft: work in progress. It expires after about six months unless a new revision is posted. The name shows the stage: `draft-<author>-...` is usually an individual draft, `draft-ietf-<wg>-...` is a WG draft, and the suffix `-NN` is the revision number. |
| WG | Working group, for example the OAuth WG or the JOSE WG. |
| Charter, milestone | A WG's charter defines its scope and its milestones (planned documents with target dates). A recharter replaces the charter. |
| BoF | "Birds of a Feather": a first IETF meeting that discusses whether to start new work. |
| IESG, AD | Internet Engineering Steering Group, which approves documents for publication; an Area Director is one of its members. |
| Adoption, Last Call | A WG adopts an individual draft to make it a WG draft. WG Last Call is the final review inside the WG. IETF Last Call is the final review by the whole IETF, before the IESG decides. |
| Datatracker | The IETF website ([datatracker.ietf.org](https://datatracker.ietf.org/)) that records the state and history of every draft, RFC and WG. Two of its states appear in this document. "WG consensus, waiting for write-up": the WG agrees, and a summary for the IESG is being written. "Waiting for AD Go-Ahead": IETF Last Call has ended, and the responsible AD reviews the comments. |
| RFC Editor queue | Documents that the IESG has approved. The RFC Editor edits them and then publishes them as RFCs. A queued document is "blocked" when it depends on a normative reference (a document that implementers must read) that is not yet published. |
| BCP | Best Current Practice: an RFC series for operational rules. One BCP number can contain several RFCs. |
| STD | The number of an Internet Standard, for example STD 66 (RFC 3986). |
| RFC status | Proposed Standard: a standards-track specification. Internet Standard: the highest level of the standards track. Best Current Practice: see BCP. Informational and Experimental: published, but not standards. |
| MUST, SHOULD, MAY | Requirement keywords defined by BCP 14 ([RFC 2119](https://www.rfc-editor.org/rfc/rfc2119.html), [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174.html)). MUST, REQUIRED: an absolute requirement. SHOULD, RECOMMENDED: do it, unless you have a valid reason not to and understand the consequences. MAY, OPTIONAL: truly optional. The words have this meaning only when they are written in capital letters. |
| Errata | Corrections found after publication. RFC errata are listed separately on the RFC Editor website, because the RFC text never changes. The OIDF publishes errata sets as new editions of a specification. |
| IANA | Internet Assigned Numbers Authority: keeps the registries of parameter names, error codes and metadata fields. |
| OIDF | OpenID Foundation: publishes OpenID Connect, FAPI and related specifications. They are not RFCs. |
| OIDC, ID Token | OpenID Connect: the identity layer on top of OAuth 2.0. Its ID Token is a signed JWT that tells the client who the user is and how they logged in. |
| RP | Relying party: the OIDC name for a client. |
| `acr`, `amr` | OIDC claims: authentication context class reference (which rules the login satisfied); authentication methods references (which methods were used). |
| FAPI | The OIDF high-security profiles of OAuth. Older editions spell the name out as "Financial-grade API" (for example the 2018 JARM draft in `../oidf-sources/`); the FAPI 2.0 specifications use only the short name. |
| Profile | A document that selects and restricts the options of a framework for one use case. For example, FAPI 2.0 is a high-security profile of OAuth. |
| JSON, JOSE | JavaScript Object Notation; JSON Object Signing and Encryption, the family of JWS, JWE, JWK and JWA. |
| JWT, JWS, JWE, JWK, JWA | JSON Web Token, Signature, Encryption, Key, Algorithms. |
| HMAC, MAC | Hash-based message authentication code; message authentication code. |
| TLS, mTLS | Transport Layer Security; mutual TLS, where the client also presents a certificate. |
| PKCE | Proof Key for Code Exchange (RFC 7636). |
| DPoP | Demonstrating Proof of Possession (RFC 9449). |
| JAR, PAR, RAR | JWT-Secured Authorization Request; Pushed Authorization Requests; Rich Authorization Requests. |
| ROPC | Resource Owner Password Credentials, the password grant. OAuth 2.1 removes it. |
| SPA, BFF | Single-page application; Backend for Frontend. |
| CORS | Cross-Origin Resource Sharing: the browser rule that lets a page call another origin. |
| CSRF, XSS, SSRF | Cross-site request forgery; cross-site scripting; server-side request forgery. |
| Open redirector | An endpoint that sends the browser on to a URL taken from the request. Attackers abuse it to steal codes and tokens, or for phishing (RFC 9700 §4.11). |
| URI, URL, URN | Uniform Resource Identifier, Locator, Name. |
| HIGH, MEDIUM, LOW | The severity of a finding in [rfc-coverage-findings/](rfc-coverage-findings/README.md). HIGH: a server generated from the YAML would break a MUST or miss a core element. MEDIUM: a SHOULD-level rule or a commonly used optional element is missing or wrong. LOW: documentation or precision. |

## 2. OAuth on one page

**2006-2008: a community fixes the password problem.** In November 2006,
developers at Twitter and Ma.gnolia were adding OpenID login. Their users had no
password to give to other sites, and no open standard existed for delegating
access to an API. At that time, a site that wanted your data from another site
usually asked for your password (the "password anti-pattern"). Otherwise, each
provider offered its own scheme (Google AuthSub, Yahoo BBAuth, AOL OpenAuth, the
Flickr and Amazon Web Services APIs). A small community wrote OAuth Core 1.0;
the final specification is dated 4 December 2007. The user approved access at
the provider, and the client received a limited, revocable token instead of the
password. Every API request was signed with shared secrets, a nonce and a
timestamp.

**2009-2010: a flaw, a rival, and a rewrite.** In 2008 the work moved to the
IETF. In April 2009 a session-fixation attack was found in the protocol itself:
an attacker could start a flow, trick a victim into approving it, and then use
the victim's access. OAuth Core 1.0 Revision A ("1.0a") fixed it in June 2009.
The new IETF OAuth WG first planned a compatible "OAuth 1.1". At the same time,
engineers from
Microsoft, Yahoo! and Google proposed OAuth WRAP (Web Resource Authorization
Profiles): no signatures, short-lived bearer tokens over HTTPS, refresh tokens
and a separate authorization server. In April 2010 the IETF published OAuth 1.0a
as Informational RFC 5849 and started OAuth 2.0 as a merge of WRAP and 1.0a. In
June 2010, draft -06 removed all signatures. This made OAuth easy to adopt. It
also meant that a stolen token works for anyone, and that problem shaped the
next thirteen years.

**2012-2015: OAuth 2.0 and its first extensions.** RFC 6749 and RFC 6750 were
published in October 2012. The core was renamed a "framework" with many optional
parts, and its lead editor resigned and publicly criticized the result. Identity
came from the OpenID Foundation: OpenID Connect (2014) added the ID Token on top
of OAuth 2.0. In 2015 the IETF published the JSON security toolkit (JOSE and
JWT), assertion grants, dynamic client registration, PKCE and token
introspection.

**2015-2023: security research drives the work.** From late 2015, formal
analysis of the protocol found the authorization-server mix-up attack. In this
attack, a client uses several authorization servers, and an attacker-controlled
server tricks the client into sending it a code or token from an honest server
(RFC 9700 §4.4). The WG answered with issuer identifiers (RFC 8414 in 2018,
RFC 9207 in 2022) and started a Security Best Current Practice that took eight
years. Native apps
moved to the system browser plus PKCE (RFC 8252, 2017). Devices without a
browser got the device grant (RFC 8628, 2019). Several attempts to bind tokens
to keys failed (MAC tokens, the 2014 proof-of-possession drafts, Token Binding)
until mutual TLS (RFC 8705, 2020) and DPoP (RFC 9449, 2023) succeeded. Between
2020 and 2023 the WG also published token exchange, resource indicators, JAR and
PAR, JWT access tokens, rich authorization requests and step-up authentication.

**2025-2026: the rules are written down.** January 2025 brought RFC 9700, the
Security BCP: PKCE (required for public clients, recommended for confidential
ones), exact redirect URI matching, no implicit grant, no password grant,
sender-constrained tokens. In the same month, researchers disclosed "audience
injection" against JWT client authentication: a malicious AS could obtain a
client's authentication JWT that an honest AS would also accept. The fix
(draft-ietf-oauth-rfc7523bis) is now in the RFC Editor queue, the last step
before publication as an RFC. In June 2026 the WG rechartered around automated
agents and digital credentials. In
August 2026 two more OAuth WG BCPs were published: RFC 10027 on cross-device
flows and RFC 10017 on browser-based apps. OAuth 2.1 collects all of these fixes
in one document. Its draft -16 (3 September 2026) removed the PKCE `plain`
method and made the `iss` response parameter mandatory. **On 10 October 2026,
OAuth 2.1 is still an Internet-Draft, not an RFC.**

## 3. The eras

Eight eras, from November 2006 to 10 October 2026. Each era has a short summary
and a table of key events. Every event comes from the research data with
`verified: true` and at least one primary source (the Source column). Local
copies are linked where they exist; statements about this repository describe its
state on 11 October 2026.

### 3.1 Origins: a community protocol for API delegation (2006-11 to 2008-11)

Before OAuth, a site that wanted a user's data from another site asked for the
user's password, or used one provider's private delegation scheme. In November
2006, developers working on OpenID at Twitter and Ma.gnolia saw that OpenID users
had no password to hand over and that no open standard existed for delegating
API access. A small community wrote OAuth Core 1.0 in 2007: a redirect-based,
three-step flow (request token, user authorization, access token) in which every
API request is signed. It was deliberately independent of OpenID. In 2008 the
specification was brought to the IETF.

| Date | Event | Why it matters | Source |
|---|---|---|---|
| 2006-11 | Blaine Cook, working on Twitter's OpenID implementation, contacts Chris Messina. With David Recordon, Larry Halff (Ma.gnolia) and others they conclude that no open standard for API access delegation exists. | This is OAuth's original problem: replace password sharing with a limited, revocable grant (oauth.net calls it a "valet key"). It also explains why OAuth is not an OpenID extension. | [oauth.net: Introduction](https://oauth.net/about/introduction/) |
| 2007-04 to 2007-07 | A Google discussion group of implementers forms in April. In July the group writes a first draft and opens to everyone. Prior art studied: Google AuthSub, AOL OpenAuth, Yahoo BBAuth, Upcoming, Flickr and AWS (Amazon Web Services) APIs. | OAuth started as a community specification, not as the product of a standards body. Later it needed the IETF for governance and change control. | [oauth.net: Introduction](https://oauth.net/about/introduction/) |
| 2007-10-03 / 2007-12-04 | OAuth Core 1.0: final draft (3 October) and final specification (4 December). Authors include Mark Atwood, Blaine Cook, Leah Culver, Eran Hammer-Lahav, Ben Laurie, Chris Messina and David Recordon. Every request is signed with HMAC-SHA1, RSA-SHA1 or PLAINTEXT and carries a nonce and timestamp. | It set the pattern that every later version keeps: send the user to the provider, give the client a token instead of a password. OAuth 2.0 dropped its per-request signatures; mTLS and DPoP later brought part of that protection back. | [OAuth Core 1.0](https://oauth.net/core/1.0/); [oauth.net/1](https://oauth.net/1/) |
| 2008-09-30 / 2008-11-17 | Eran Hammer-Lahav submits draft-hammer-oauth-00, an IETF-format copy of the community specification. An OAuth BoF meets at IETF 73 in Minneapolis (chairs Sam Hartman and Mark Nottingham). | The start of the move from an informal community to IETF change control, which led to both RFC 5849 and OAuth 2.0. | [draft-hammer-oauth](https://datatracker.ietf.org/doc/draft-hammer-oauth/); [IETF 73 minutes](https://www.ietf.org/proceedings/73/minutes/oauth.txt) |

### 3.2 Crisis, WRAP and the decision to rewrite (2009-03 to 2010-08)

2009 brought OAuth's first protocol-level vulnerability (session fixation), fixed
by OAuth Core 1.0 Revision A, and an IETF WG chartered to produce a
backward-compatible "OAuth 1.1". In parallel, engineers from Microsoft, Yahoo! and
Google proposed OAuth WRAP (Web Resource Authorization Profiles): no signatures,
short-lived bearer tokens over HTTPS, refresh tokens and a separate authorization
server. By mid-2010 the IETF had published the community protocol as
Informational RFC 5849 and had started OAuth 2.0 as a merge of WRAP and 1.0a.
Draft -06 then removed all signatures and all discovery from the core.

| Date | Event | Why it matters | Source |
|---|---|---|---|
| 2009-03-23 to 2009-05-12 | A second BoF meets at IETF 74 (San Francisco). The OAuth WG starts on 12 May 2009. Its first charter says: start from draft-hammer-oauth, "update OAuth 1.0 to become OAuth 1.1", keep backward compatibility where possible, do not modify the three existing signature methods. | The original IETF plan was evolution. The jump to an incompatible 2.0 was a later change of direction. | [IETF 74 minutes](https://www.ietf.org/proceedings/74/minutes/oauth.txt); [charter-01](https://www.ietf.org/charter/charter-ietf-oauth-01.txt) |
| 2009-04-23 | OAuth Security Advisory 2009.1, session fixation: an attacker starts the flow, saves the authorization URL that contains the attacker's request token, and tricks a victim into approving it. All standards-compliant three-legged implementations were affected. | OAuth's first protocol-level flaw. Lesson: bind every step of a redirect flow to the user and session that started it. The idea returns as `state`, PKCE and DPoP code binding. | [Advisory 2009.1](https://oauth.net/advisories/2009-1/); [explainer (archived)](https://web.archive.org/web/20090912004026/http://hueniverse.com:80/2009/04/explaining-the-oauth-session-fixation-attack/) |
| 2009-06-24 | OAuth Core 1.0 Revision A ("1.0a"): `oauth_callback` moves into the signed request, the provider confirms it, and the provider returns an unguessable `oauth_verifier` that the client must present to get the access token. | A one-time value sent through the browser and checked on the back channel. The same pattern returns as the authorization code plus the PKCE verifier. | [OAuth Core 1.0a](https://oauth.net/core/1.0a/) |
| 2009-11 to 2010-01-15 | OAuth WRAP, draft-hardt-oauth-01 (D. Hardt and Y. Goland of Microsoft, A. Tom of Yahoo!, B. Eaton of Google): short-lived opaque bearer access tokens over HTTPS, long-lived refresh tokens, a separate authorization server, and profiles for different kinds of clients. | The architectural parent of OAuth 2.0. Its username/password and assertion profiles are the ancestors of ROPC and of RFC 7521-7523. | [draft-hardt-oauth-01](https://www.ietf.org/archive/id/draft-hardt-oauth-01.txt); [WRAP group (archived)](https://web.archive.org/web/20091123085939/http://groups.google.com:80/group/oauth-wrap-wg) |
| 2010-04-20 | [RFC 5849](../rfc-sources/rfc5849.txt) is published as Informational, outside any WG: it is "not an item of the IETF's OAuth Working Group" and was transferred "for change control". RFC 6749 obsoleted it in 2012. | This is why OAuth 1.0 never became a standard: the IETF recorded the deployed protocol while the WG built an incompatible successor. | [RFC 5849](../rfc-sources/rfc5849.txt); [charter-03](https://www.ietf.org/charter/charter-ietf-oauth-03.txt) |
| 2010-04-29 | draft-ietf-oauth-v2-00: "Initial draft based on a combination of WRAP and OAuth 1.0a." | The "OAuth 1.1" plan is dropped. OAuth 2.0 is an incompatible redesign around WRAP's architecture. | [draft-ietf-oauth-v2-00](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-00.txt) |
| 2010-06-09 | draft-ietf-oauth-v2-06: "Removed all signature and cryptography", "Removed all discovery". From now on the core relies on TLS and bearer tokens. | The most important design decision in OAuth's history. It traded protection against token theft and replay for simplicity. MAC tokens, Token Binding, mTLS and DPoP worked on this gap for the next 13 years. Discovery came back only with OIDC (2014) and RFC 8414 (2018). | [draft-06](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-06.txt) |
| 2010-08-31 | Twitter: "Basic Auth has been deprecated. All applications must now use OAuth." (OAuth 1.0a at the time.) | Large-scale proof that delegated tokens can replace passwords for API access. | [dev.twitter.com (archived)](https://web.archive.org/web/20100901044917/http://dev.twitter.com/) |

### 3.3 OAuth 2.0: framework, bearer tokens and a public split (2010-11 to 2013-08)

The WG split token presentation into a Bearer specification and a competing MAC
specification. It rechartered around a standards-track OAuth 2.0 and renamed the
core an "Authorization Framework" that openly depends on future profiles for
interoperability. Its lead editor resigned and criticized the result in public.
RFC 6749 and RFC 6750 were published in October 2012 with bearer tokens and many
optional parts. The threat model (RFC 6819) and token revocation (RFC 7009)
followed, while academic studies showed how often real deployments got OAuth
wrong.

| Date | Event | Why it matters | Source |
|---|---|---|---|
| 2010-11-30 / 2011-01-09 | draft-ietf-oauth-v2-bearer-00 moves token presentation out of the core (M. Jones, editor). Eran Hammer-Lahav proposes MAC tokens (draft-hammer-oauth-v2-mac-token-00); the WG adopts them in May 2011. | Bearer versus proof of possession becomes a choice of token type (RFC 6749 §7.1, `token_type`). Bearer tokens were published first; proof of possession was postponed. | [bearer-00](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-bearer-00.txt); [mac-token-00](https://www.ietf.org/archive/id/draft-hammer-oauth-v2-mac-token-00.txt) |
| 2011-06-14 | Recharter (charter-03): OAuth 2.0 goes on the standards track. Deliverables include a MAC scheme, a bearer token specification, a SAML (Security Assertion Markup Language) assertion grant and a security analysis. | The formal record of the change from 1.1 to 2.0. The work items became RFC 6750, RFC 7522 and RFC 6819; the MAC scheme never became an RFC. | [charter-03](https://www.ietf.org/charter/charter-ietf-oauth-03.txt) |
| 2012-05-01 | draft-ietf-oauth-v2-26 renames the core "The OAuth 2.0 Authorization Framework" and keeps the interoperability warning, now §1.8: a framework with "many optional components" is "likely to produce a wide range of non-interoperable implementations". | This is why OAuth needs profiles (OIDC, FAPI, OAuth 2.1). RFC 6749 alone guarantees neither interoperability nor security; the implementer of an AS must choose secure defaults. | [draft-26](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-26.txt); [RFC 6749 §1.8](../rfc-sources/rfc6749.txt) |
| 2012-06 to 2012-07-26 | The lead editor, Eran Hammer (published earlier as Eran Hammer-Lahav), resigns. Draft -29 (12 July) removes their name from the author list at their request, and Dick Hardt becomes the sole editor. Their post "OAuth 2.0 and the Road to Hell" calls 2.0 "a bad protocol" and lists weak points, including bearer tokens that rely only on TLS, expiring tokens, many grant types and "No useful support for native applications". | The post is a useful map of the weak spots of 2.0. Most were later fixed by the native-apps BCP, PKCE, sender-constrained tokens, the Security BCP and OAuth 2.1. | [post (archived)](https://web.archive.org/web/20120728020635/http://hueniverse.com:80/2012/07/oauth-2-0-and-the-road-to-hell/); [draft-28](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-28.txt); [draft-29](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-29.txt) |
| 2012-10-13 | [RFC 6749](../rfc-sources/rfc6749.txt) and [RFC 6750](../rfc-sources/rfc6750.txt) are published as Proposed Standards; RFC 6749 obsoletes RFC 5849. [RFC 6755](../rfc-sources/rfc6755.txt), the `urn:ietf:params:oauth` namespace, came on 5 October. | The base that every later OAuth document extends. RFC 6749 was later updated by RFC 8252, RFC 8996 and RFC 9700. | [RFC 6749](../rfc-sources/rfc6749.txt); [draft-ietf-oauth-v2](https://datatracker.ietf.org/doc/draft-ietf-oauth-v2/) |
| 2012-10 to 2014-11 | Academic studies of deployed OAuth: Sun and Beznosov (Conference on Computer and Communications Security, CCS 2012); Bansal, Bhargavan, Delignat-Lavaud and Maffeis (Journal of Computer Security, 2014); Chen et al. (CCS 2014). RFC 9700 §7.2 cites all three. | Optional features produced insecure deployments. This evidence motivated the threat model, PKCE and the Security BCP. | [RFC 9700 §7.2](../rfc-sources/rfc9700.txt) |
| 2013-01-08 | [RFC 6819](../rfc-sources/rfc6819.txt), threat model and security considerations (T. Lodderstedt, M. McGloin, P. Hunt). | The first systematic security analysis of OAuth 2.0. RFC 9700 §3 later made its attacker model explicit and stronger. | [RFC 6819](../rfc-sources/rfc6819.txt) |
| 2013-08-22 | [RFC 7009](../rfc-sources/rfc7009.txt), token revocation. | The first standard token-lifecycle endpoint after the core. | [RFC 7009](../rfc-sources/rfc7009.txt) |

### 3.4 Identity layer, JSON security and the first extension wave (2014-02 to 2015-10)

OpenID Connect (February 2014) added an authentication layer on top of OAuth 2.0
with signed JSON ID Tokens. The JOSE suite and JWT (May 2015) standardized JSON
signing, encryption and keys. 2015 also brought the assertion framework (SAML and
JWT grants, and `private_key_jwt` client authentication), Dynamic Client
Registration, PKCE and token introspection. The WG dropped MAC tokens for a
broader proof-of-possession plan. Attacks on JWT libraries showed the danger of
letting a token choose its own algorithm.

| Date | Event | Why it matters | Source |
|---|---|---|---|
| 2014-02-26 | OpenID Connect 1.0 is final: Core, Discovery, Dynamic Registration and Multiple Response Types (the member vote closed on 25 February). Form Post became final on 27 April 2015. On 7 October 2024 the OIDF announced that nine OIDC specifications had been published as ISO/IEC 26131-26139:2024 (ISO/IEC: the International Organization for Standardization and the International Electrotechnical Commission). | OAuth is delegation, not login. OIDC adds the ID Token (a JWT with `iss`, `sub`, `aud`, `nonce`) and the UserInfo endpoint, and it created the discovery and registration patterns that OAuth later generalized. Local copies: [Core](../oidf-sources/oidc-core-1.0.html), [Discovery](../oidf-sources/oidc-discovery-1.0.html). | [self-issued.info, Feb 2014](https://self-issued.info/?m=201402); [OIDF: ISO publication](https://openid.net/10-years-on-openidconnect-published-as-iso-spec/) |
| 2014-05-08 / 2014-07-21 | The WG deletes its MAC milestones and adopts four proof-of-possession drafts: pop-architecture, pop-key-distribution, signed-http-request and proof-of-possession. Only the last one became an RFC (RFC 7800). The MAC draft stops at -05 (15 January 2014). | The first attempt to bring back signatures failed. The WG generalized the problem instead, and no general key-binding mechanism succeeded until mTLS (2020) and DPoP (2023). | [WG events](https://datatracker.ietf.org/api/v1/group/groupevent/?group=1748&format=json&limit=300); [http-mac-05](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-http-mac-05.txt) |
| 2015-03 | Tim McLean publishes "Critical vulnerabilities in JSON Web Token libraries": some libraries accept `alg: none`; others verify an `RS256` token as `HS256` and use the RSA public key as the HMAC secret (CVE-2015-9235; CVE: Common Vulnerabilities and Exposures). | Algorithm agility without an allow-list is dangerous. This led to RFC 8725 (2020), explicit JWT typing, and the 2026 work to deprecate `none` and `RSA1_5`. | [RFC 8725 §2.1](../rfc-sources/rfc8725.txt); [Auth0 blog](https://auth0.com/blog/critical-vulnerabilities-in-json-web-token-libraries/) |
| 2015-05-19 | Published on the same day: JOSE [RFC 7515](../rfc-sources/rfc7515.txt) (JWS), [RFC 7516](../rfc-sources/rfc7516.txt) (JWE), [RFC 7517](../rfc-sources/rfc7517.txt) (JWK) and [RFC 7518](../rfc-sources/rfc7518.txt) (JWA); [RFC 7519](../rfc-sources/rfc7519.txt) (JWT); and the assertion framework [RFC 7521](../rfc-sources/rfc7521.txt) with its SAML ([RFC 7522](../rfc-sources/rfc7522.txt)) and JWT ([RFC 7523](../rfc-sources/rfc7523.txt)) profiles. | JSON-native signing, encryption and keys replaced XML-era formats. JWTs became ID Tokens, client assertions, request objects, JWT access tokens and DPoP proofs. All eight RFCs are now vendored. | [RFC 7515](../rfc-sources/rfc7515.txt); [RFC 7519](../rfc-sources/rfc7519.txt); [RFC 7521](../rfc-sources/rfc7521.txt); [draft-jones-json-web-token](https://datatracker.ietf.org/doc/draft-jones-json-web-token/) |
| 2015-07-09 | [RFC 7591](../rfc-sources/rfc7591.txt) Dynamic Client Registration and [RFC 7592](../rfc-sources/rfc7592.txt) registration management (Experimental). | OAuth can now work in open ecosystems where a client meets authorization servers it was never configured for. This is also the setting in which an attacker can run an AS that a client talks to (mix-up). The YAML has `registration_endpoint` but no `/register` path ([dcr findings](rfc-coverage-findings/dcr.md)). | [RFC 7591](../rfc-sources/rfc7591.txt); [RFC 7592](../rfc-sources/rfc7592.txt) |
| 2015-09-16 | [RFC 7636](../rfc-sources/rfc7636.txt) PKCE. It began as draft-sakimura-oauth-tcse-00 (29 July 2013) and was adopted by the WG in August 2014. The attack it stops: a malicious app registers the same custom URI scheme and intercepts the authorization code. | The most influential extension after 2012. It started as a fix for native apps; RFC 9700 later showed that it also stops code injection and CSRF. OAuth 2.1 requires it, and draft -16 removed `plain`. | [draft-sakimura-oauth-tcse-00](https://www.ietf.org/archive/id/draft-sakimura-oauth-tcse-00.txt); [draft-ietf-oauth-spop-00](https://www.ietf.org/archive/id/draft-ietf-oauth-spop-00.txt); [RFC 7636](../rfc-sources/rfc7636.txt) |
| 2015-10-19 | [RFC 7662](../rfc-sources/rfc7662.txt) Token Introspection. Before it, vendors used shared databases, service buses or self-contained JWTs. | Standardized opaque tokens with real-time status: the alternative to self-contained JWT access tokens. | [RFC 7662](../rfc-sources/rfc7662.txt); [draft-richer-oauth-introspection](https://datatracker.ietf.org/doc/draft-richer-oauth-introspection/) |

### 3.5 The security research turn (2015-11 to 2019-08)

Formal analysis of OAuth in a detailed model of the web (Fett, Küsters and
Schmitz) found attacks in the specification itself, the most important being the
authorization-server mix-up. This led to a WG advisory, a 2016 recharter, the
OAuth Security Workshop and the multi-year Security BCP. Discovery returned with
issuer-anchored AS metadata (RFC 8414). Native apps got a BCP that requires the
system browser and PKCE (RFC 8252). Devices without a browser got the device
grant (RFC 8628). The BCP drafts deprecated the implicit and password grants.
Token Binding, the TLS-layer answer to bearer-token theft, was standardized just
as Chrome abandoned it, and DPoP was proposed as an application-layer
alternative.

| Date | Event | Why it matters | Source |
|---|---|---|---|
| 2015-11 to 2016-01-10 | The WG chairs learn of unpublished attacks on clients that use more than one AS (November 2015); a small group meets in Darmstadt in December. Fett, Küsters and Schmitz post "A Comprehensive Formal Security Analysis of OAuth 2.0" (arXiv:1601.01229, 6 January 2016) with four attacks that break OAuth and also affect OIDC. Hannes Tschofenig posts the WG advisory "Authorization Server Mix-Up" (10 January 2016) with an interim fix: a separate redirect URI for each AS. | OAuth security moved from careful implementation to formal analysis of the protocol itself. The fixes followed over ten years: the RFC 8414 `issuer`, the RFC 9207 `iss` parameter, RFC 9700 §4.4, and `iss` REQUIRED in OAuth 2.1 -16. | [arXiv:1601.01229](https://arxiv.org/abs/1601.01229); [WG advisory](https://mailarchive.ietf.org/arch/msg/oauth/JIVxFBGsJBVtm7ljwJhPUm3Fr-w/); [RFC 9700 §4.4](../rfc-sources/rfc9700.txt) |
| 2016-01-22 | The IESG approves charter-05. In March 2016 the WG adds milestones: mix-up mitigation, closing open redirectors, AS discovery metadata, AMR (Authentication Method Reference) values, device flow, native apps, and the proof-of-possession documents. | About half became RFCs (7800, 8176, 8252, 8414, 8628). The rest died (see section 5). | [charter history](https://datatracker.ietf.org/doc/charter-ietf-oauth/); [WG events](https://datatracker.ietf.org/api/v1/group/groupevent/?group=1748&format=json&limit=300) |
| 2016-07-14 / 2016-07-15 | The first OAuth Security Workshop (OSW 2016) at the University of Trier. Research groups in Bochum and Trier had found attacks independently and first met in Darmstadt in 2015. OSW 2025 met in Reykjavik and OSW 2026 in Leipzig. | It made the loop from researchers to the WG a permanent institution. That loop later produced the Security BCP, DPoP and the 2025 response to audience injection. | [OSW 2016](https://osw2016.sec.uni-stuttgart.de/); [IDPro on OSW 2025](https://idpro.org/the-oauth-security-workshop-2025/); [self-issued.info](https://self-issued.info/?p=2861) |
| 2016-11-13 / 2017-03-27 | The Security BCP starts as draft-lodderstedt-oauth-security-topics-00 and becomes WG draft draft-ietf-oauth-security-topics-00. It went through 30 revisions (-00 to -29) before IESG approval on 14 June 2024. | For years this draft, not an RFC, was the practical rule set for OAuth 2.0 security. | [individual draft](https://datatracker.ietf.org/doc/draft-lodderstedt-oauth-security-topics/); [WG draft](https://datatracker.ietf.org/doc/draft-ietf-oauth-security-topics/) |
| 2017-10-04 | [RFC 8252](../rfc-sources/rfc8252.txt) OAuth 2.0 for Native Apps (BCP 212). Native apps must not use embedded web-views (§8.12). They use the external browser and receive the response through a private-use URI scheme, a claimed https URL or a loopback address (§7). Public native clients must use PKCE (§6). It formally updates RFC 6749. | The first BCP to override an option of RFC 6749 (§9). It answered the 2012 complaint about native applications. | [RFC 8252](../rfc-sources/rfc8252.txt); [draft-wdenniss-oauth-native-apps](https://datatracker.ietf.org/doc/draft-wdenniss-oauth-native-apps/) |
| 2018-06-28 | [RFC 8414](../rfc-sources/rfc8414.txt) Authorization Server Metadata. `issuer` is REQUIRED and is "used to prevent authorization server mix-up attacks" (§2); clients must validate it (§3.3). | Discovery returned to OAuth eight years after draft-06 removed it. The issuer identifier became the anchor for the mix-up fixes and later for the audience-injection fix. | [RFC 8414](../rfc-sources/rfc8414.txt); [draft-jones-oauth-discovery](https://datatracker.ietf.org/doc/draft-jones-oauth-discovery/) |
| 2018-08-01 to 2018-10-19 | A Chrome engineer posts "Intent to Remove: Token Binding": it was never on by default, had little adoption, and was attempted on fewer than 0.01% of HTTPS requests. RFC 8471-8473 are still published on 9 October 2018. The OAuth Token Binding draft stops at -08 (19 October 2018) and expires; the tokbind WG closes in March 2021. | A technically clean TLS-layer proof of possession failed because browsers did not support it. RFC 9449 §1 names the "lack of support for HTTP token binding" as one reason DPoP exists. | [blink-dev thread](https://groups.google.com/a/chromium.org/g/blink-dev/c/OkdLUyYmY1E/m/YJrsadYKDQAJ); [RFC 8471](https://www.rfc-editor.org/rfc/rfc8471.html); [draft-ietf-oauth-token-binding](https://datatracker.ietf.org/doc/draft-ietf-oauth-token-binding/) |
| 2018-11-09 / 2019-07-08 | Security BCP draft -09 "changed text to recommend not to use implicit but code". Draft -13 discourages the password grant and says "AS MUST support PKCE" and "PKCE may replace state for CSRF protection". | In practice this ended the implicit grant for SPAs (replaced by code + PKCE over CORS) and the password grant. The YAML excludes both on purpose. | [security-topics-29](https://www.ietf.org/archive/id/draft-ietf-oauth-security-topics-29.txt); [WG draft history](https://datatracker.ietf.org/doc/draft-ietf-oauth-security-topics/) |
| 2019-03-27 | DPoP is proposed: draft-fett-oauth-dpop-00 (D. Fett, J. Bradley, B. Campbell, T. Lodderstedt, M. Jones). WG adoption follows on 1 April 2020. It arrived two months after a formal analysis of the OpenID FAPI (arXiv:1901.11520). | The proof-of-possession design that finally succeeded: simple enough for the browser (keys from WebCrypto, the browser's Web Cryptography API), with no dependency on the TLS layer. | [draft-fett-oauth-dpop-00](https://www.ietf.org/archive/id/draft-fett-oauth-dpop-00.txt); [draft-ietf-oauth-dpop](https://datatracker.ietf.org/doc/draft-ietf-oauth-dpop/); [RFC 9700 §3](../rfc-sources/rfc9700.txt) |
| 2019-08-17 | [RFC 8628](../rfc-sources/rfc8628.txt) Device Authorization Grant, for TVs, consoles and printers. §5.4 already warns about remote phishing. | OAuth reached devices without a browser. It also created the cross-device phishing problem that RFC 10027 addressed in 2026. | [RFC 8628](../rfc-sources/rfc8628.txt); [draft-denniss-oauth-device-flow](https://datatracker.ietf.org/doc/draft-denniss-oauth-device-flow/) |

### 3.6 Sender-constrained tokens, rich requests and consolidation (2020-01 to 2023-12)

The 2020 wave delivered token exchange, certificate-bound tokens over mutual
TLS, resource indicators and the JWT BCP. OAuth 2.1 began as a consolidation of
RFC 6749 plus a decade of fixes, while the GNAP (Grant Negotiation and
Authorization Protocol) WG started work on a completely new, incompatible
successor. In 2021 the WG
formally dropped the dead proof-of-possession and mix-up drafts in favor of DPoP
and the `iss` parameter. By 2023 it had also published front-channel hardening
(JAR, PAR), interoperable JWT access tokens, fine-grained authorization (RAR),
DPoP and step-up authentication. Open banking and FAPI drove much of this work.

| Date | Event | Why it matters | Source |
|---|---|---|---|
| 2020-01-15 to 2020-02-29 | [RFC 8693](../rfc-sources/rfc8693.txt) Token Exchange (15 January), [RFC 8725](../rfc-sources/rfc8725.txt) JWT BCP (BCP 225, 19 February), [RFC 8705](../rfc-sources/rfc8705.txt) mutual TLS and [RFC 8707](../rfc-sources/rfc8707.txt) Resource Indicators (both 29 February). | mTLS gave OAuth its first standard sender-constrained tokens. Together these are the building blocks of high-security profiles (FAPI) and of service-to-service delegation. | [RFC 8693](../rfc-sources/rfc8693.txt); [RFC 8705](../rfc-sources/rfc8705.txt); [RFC 8707](../rfc-sources/rfc8707.txt); [RFC 8725](../rfc-sources/rfc8725.txt) |
| 2020-03 / 2020-07-30 | D. Hardt, A. Parecki and T. Lodderstedt post draft-parecki-oauth-v2-1-00 (dated 7 March 2020), which "replaces and obsoletes" RFC 6749. The WG adopts it on 30 July 2020. A March 2021 milestone targeted IESG submission in July 2021; that did not happen. | OAuth chose consolidation over reinvention: one baseline from RFC 6749/6750, PKCE, the native and browser BCPs and the Security BCP. By coincidence, in 2012 the departing editor had hoped for "A 2.1 that's really 1.5". | [draft-parecki-oauth-v2-1-00](https://www.ietf.org/archive/id/draft-parecki-oauth-v2-1-00.txt); [draft-ietf-oauth-v2-1-00](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-1-00.txt); [2012 post (archived)](https://web.archive.org/web/20120728020635/http://hueniverse.com:80/2012/07/oauth-2-0-and-the-road-to-hell/) |
| 2020-07-10 | The GNAP WG is chartered. It grew from Justin Richer's "Transactional Authorization" draft (15 May 2019) and a TxAuth (Transactional Authorization) BoF at IETF 106 (November 2019). Its goal is a new delegation protocol that is not backward-compatible. | The IETF ran a start-over track in parallel with the OAuth 2.1 consolidation. | [draft-richer-transactional-authz](https://datatracker.ietf.org/doc/draft-richer-transactional-authz/); [GNAP WG history](https://datatracker.ietf.org/group/gnap/history/) |
| 2021-03-02 | The WG deletes the milestones for mix-up mitigation, closing open redirectors, PoP key distribution and signed HTTP requests. It adds milestones for PAR, the Security BCP, OAuth 2.1, browser-based apps, DPoP and the `iss` authorization response parameter. | The official end of the 2014-2016 proof-of-possession plan. DPoP and RFC 9207 became the chosen fixes. | [WG events](https://datatracker.ietf.org/api/v1/group/groupevent/?group=1748&format=json&limit=300) |
| 2021-08-21 to 2021-10-21 | [RFC 9101](../rfc-sources/rfc9101.txt) JAR (21 August; it traces back to draft-sakimura-oauth-requrl of June 2010), [RFC 9126](../rfc-sources/rfc9126.txt) PAR (15 September), [RFC 9068](../rfc-sources/rfc9068.txt) JWT access tokens (21 October). The OIDF's CIBA (Client-Initiated Backchannel Authentication) Core 1.0 becomes final on 1 September 2021 ([local copy](../oidf-sources/openid-client-initiated-backchannel-authentication-core-1_0.html)). | The front channel was hardened: request parameters became signed objects or authenticated back-channel pushes. JWT access tokens became interoperable. | [RFC 9101](../rfc-sources/rfc9101.txt); [RFC 9126](../rfc-sources/rfc9126.txt); [RFC 9068](../rfc-sources/rfc9068.txt); [CIBA Core](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html) |
| 2022-03-18 / 2022-08-09 | [RFC 9207](../rfc-sources/rfc9207.txt) AS issuer identification (K. Meyer zu Selhausen and D. Fett) adds `iss` to authorization responses. [RFC 9278](../rfc-sources/rfc9278.txt) defines a URI form of key thumbprints. | One simple parameter finally closed the 2016 mix-up gap. | [RFC 9207](../rfc-sources/rfc9207.txt); [RFC 9278](../rfc-sources/rfc9278.txt) |
| 2023-05-30 | [RFC 9396](../rfc-sources/rfc9396.txt) Rich Authorization Requests. The motivating example is "please let me transfer an amount of 45 Euros to Merchant A", which a scope string cannot express. | Fine-grained, transaction-specific consent for open banking, e-health and electronic signing. | [RFC 9396](../rfc-sources/rfc9396.txt) |
| 2023-09 | [RFC 9449](../rfc-sources/rfc9449.txt) DPoP and [RFC 9470](../rfc-sources/rfc9470.txt) step-up authentication (published on 7 and 8 September). DPoP adds a signed proof JWT to every request (`htm`, `htu`, `iat`, `jti`, `ath`, optional `nonce`), binds tokens to the key (`cnf.jkt`) and can bind the authorization code (`dpop_jkt`, §10). By design it does not sign bodies or headers (§11.7). | Sender constraint became usable by public clients and SPAs, 13 years after draft-06 removed signatures. | [RFC 9449](../rfc-sources/rfc9449.txt); [RFC 9470](../rfc-sources/rfc9470.txt) |

### 3.7 The Security BCP, a rival protocol, and digital credentials (2024-02 to 2025-11)

Generic HTTP message signing was finally standardized outside OAuth (RFC 9421).
GNAP was published (RFC 9635) and its WG closed. January 2025 brought both the
long-awaited Security BCP (RFC 9700, BCP 240) and a new formal-analysis finding,
audience injection against JWT client authentication, handled through
coordinated disclosure and a draft update to RFC 7523. FAPI 2.0 became final. The
Model Context Protocol (MCP) made OAuth 2.1 and RFC 9728 the authorization layer
of its ecosystem. The WG's work moved toward digital credentials (SD-JWT, Selective
Disclosure for JWTs).

| Date | Event | Why it matters | Source |
|---|---|---|---|
| 2024-02-14 | RFC 9421 HTTP Message Signatures (httpbis WG; A. Backman, J. Richer, M. Sporny): signatures over selected HTTP message components that survive changes by intermediaries. | General HTTP request signing was standardized outside OAuth, 14 years after OAuth 2.0 dropped the signatures of OAuth 1.0. GNAP uses it; OAuth's sender constraint stayed with DPoP and mTLS. | [RFC 9421](https://www.rfc-editor.org/rfc/rfc9421.html) |
| 2024-10-08 | RFC 9635 GNAP is published (IESG approval 17 March 2024), and the GNAP WG closes the same month; RFC 9767 follows on 2025-04-23. GNAP "is not an extension of OAuth 2.0 and is not intended to be directly compatible"; its Appendix A lists the differences. | A next-generation alternative exists, but it expects to "exist in parallel" with OAuth. The OAuth WG keeps extending OAuth. | [RFC 9635](https://www.rfc-editor.org/rfc/rfc9635.html); [RFC 9767](https://www.rfc-editor.org/rfc/rfc9767.html) |
| 2025-01-24 to 2025-04-07 | Audience injection. Pedram Hosseyni, Ralf Küsters and Tim Würtele (University of Stuttgart) find it while analysing a pre-final version of OpenID Federation. Ambiguous `aud` (audience) values in client-authentication JWTs (for example `private_key_jwt`) let a malicious AS obtain an assertion that an honest AS will accept. OIDF disclosure notice on 24 January. The WG interim meeting on 27 January converges on "audience = issuer", and draft-jones-oauth-rfc7523bis-00 appears the same day. The full paper is ePrint 2025/629 of the International Association for Cryptologic Research (received 7 April 2025). | The second major specification bug found by formal analysis. The fix makes the issuer identifier the only allowed `aud` of client-authentication JWTs and adds the `typ` value `client-authentication+jwt` (rfc7523bis, now in the RFC Editor queue). The YAML does not say this yet ([assertions findings](rfc-coverage-findings/assertions.md)). | [OIDF notice](https://openid.net/wp-content/uploads/2025/01/OIDF-Responsible-Disclosure-Notice-on-Security-Vulnerability-for-private_key_jwt.pdf); [interim minutes](https://datatracker.ietf.org/meeting/interim-2025-oauth-04/materials/minutes-interim-2025-oauth-04-202501271700-00); [ePrint 2025/629](https://eprint.iacr.org/2025/629); [rfc7523bis-11](https://www.ietf.org/archive/id/draft-ietf-oauth-rfc7523bis-11.txt) |
| 2025-01-30 | [RFC 9700](../rfc-sources/rfc9700.txt), the Security BCP (BCP 240; IESG approval 14 June 2024), and [RFC 9701](../rfc-sources/rfc9701.txt), JWT introspection responses. RFC 9700 updates RFC 6749, 6750 and 6819. Its main rules: public clients MUST use PKCE (§2.1.1); the implicit grant SHOULD NOT be used (§2.1.2); the password grant MUST NOT be used (§2.4); access tokens SHOULD be sender-constrained (§2.2.1); public-client refresh tokens MUST be sender-constrained or rotated (§2.2.2). §3 gives an explicit attacker model. | The normative security baseline for any modern AS, and the source of most OAuth 2.1 changes. | [RFC 9700](../rfc-sources/rfc9700.txt); [RFC 9701](../rfc-sources/rfc9701.txt); [BCP 240](https://www.rfc-editor.org/info/bcp240) |
| 2025-02-22 | The OIDF's FAPI 2.0 Security Profile becomes final. The AS supports only confidential clients, requires PAR, PKCE with S256 and `iss`, issues only sender-constrained tokens (mTLS or DPoP), authenticates clients with mTLS or `private_key_jwt`, and accepts only its own issuer as `aud` in client assertions. | The clearest example of the idea that OAuth is a framework made secure by a profile, and a ready-made set of defaults for a new AS. | [FAPI 2.0 Security Profile](https://openid.net/specs/fapi-security-profile-2_0-final.html) |
| 2025-03-26 to 2025-11-25 | The MCP authorization specification: version 2025-03-26 says "MCP auth implementations MUST implement OAuth 2.1"; version 2025-06-18 requires MCP servers to implement RFC 9728; version 2025-11-25 says that authorization servers and clients SHOULD support OAuth Client ID Metadata Documents. | A large new ecosystem adopted OAuth 2.1 before it became an RFC. This raised demand for protected resource metadata, Client ID Metadata Documents and delegation for automated agents, the themes of the June 2026 recharter. | [MCP 2025-03-26](https://modelcontextprotocol.io/specification/2025-03-26/basic/authorization); [MCP 2025-06-18](https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization); [MCP 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization) |
| 2025-04-23 | [RFC 9728](../rfc-sources/rfc9728.txt) Protected Resource Metadata. It traces back to draft-jones-oauth-resource-metadata-00 (3 August 2016): about nine years from idea to RFC. | It completes discovery: clients (RFC 7591), authorization servers (RFC 8414) and now resources. | [RFC 9728](../rfc-sources/rfc9728.txt); [draft-jones-oauth-resource-metadata](https://datatracker.ietf.org/doc/draft-jones-oauth-resource-metadata/) |
| 2025-07 / 2025-09 | OpenID for Verifiable Presentations 1.0 (July) and OpenID for Verifiable Credential Issuance 1.0 (16 September) become final. | These OAuth-based credential protocols are the main users of SD-JWT, SD-JWT VC (SD-JWT-based verifiable credentials) and Token Status List. This is why digital credentials became an OAuth WG work item in 2026. | [OIDF: presentations final](https://openid.net/openid-for-verifiable-presentations-1-0-final-specification-approved/); [OIDF: issuance final](https://openid.net/openid-for-verifiable-credential-issuance-1-final-specification-approved/) |
| 2025-11-20 | [RFC 9901](../rfc-sources/rfc9901.txt) SD-JWT: salted-hash disclosures let a holder reveal only some claims of an issuer-signed JWT. | It moves the OAuth WG from API authorization into digital identity (issuer, holder, verifier). It is vendored but outside the AS HTTP surface. | [RFC 9901](../rfc-sources/rfc9901.txt) |

### 3.8 2026: consolidation, credentials and agents (2026-01 to 2026-10-10)

In 2026 OAuth is mostly being finished and hardened. OpenID Federation 1.0 became
final. Two new BCPs were published: RFC 10027 on cross-device flows, and RFC
10017 on browser-based apps, which joins RFC 8252 in BCP 212. The WG rechartered
around automated agents and digital credentials. OAuth 2.1 draft -16 removed PKCE
`plain` and made `iss` mandatory; IESG submission is targeted for December 2026.
Several near-final documents wait in the RFC Editor queue (rfc7523bis, Token
Status List, identity chaining, the JWT BCP update), and an update to RFC 9700 is
already collecting new attacks. JOSE is removing its weakest algorithms and
adding post-quantum signatures. On 10 October 2026, OAuth 2.1 is still not an
RFC.

| Date | Event | Why it matters | Source |
|---|---|---|---|
| 2025-10-30 to 2026-10-09 | JOSE modernization: [RFC 9864](../rfc-sources/rfc9864.txt) fully-specified algorithms (30 October 2025; updates RFC 7518). On 20 May 2026, RFC 9964 adds ML-DSA to JOSE and to COSE. ML-DSA (Module-Lattice-Based Digital Signature Algorithm) is a post-quantum signature algorithm. COSE is CBOR Object Signing and Encryption, the JOSE counterpart for CBOR (Concise Binary Object Representation). draft-ietf-jose-deprecate-none-rsa15-06 deprecates JWS `none` and JWE `RSA1_5`; it completed IETF Last Call and is at "Waiting for AD Go-Ahead" on 9 October 2026. | The algorithm layer under every JWT is being made safer and prepared for post-quantum cryptography. | [RFC 9864](../rfc-sources/rfc9864.txt); [RFC 9964](https://www.rfc-editor.org/rfc/rfc9964.html); [deprecate-none-rsa15](https://datatracker.ietf.org/doc/draft-ietf-jose-deprecate-none-rsa15/) |
| 2025-12-01 to 2026-07-06 | draft-ietf-oauth-security-topics-update becomes a WG document (-03 on 6 July 2026). It updates OAuth 2.0 security practice "by extending the security advice given in RFC 6749, RFC 6750, and RFC 9700": audience injection, cross-toolkit OAuth account takeover, cross-user OAuth session fixation, and shared consent in brokered OAuth. | Security guidance keeps changing. An AS built in 2026 should follow this draft, not only RFC 9700. | [security-topics-update](https://datatracker.ietf.org/doc/draft-ietf-oauth-security-topics-update/) |
| 2026-02-17 | OpenID Federation 1.0 becomes final. Analysis of a pre-final version of this specification is what found audience injection. | Trust-chain-based federation for OAuth and OIDC, for ecosystems with many authorization servers, where mix-up and audience bugs happen. | [OIDF announcement](https://openid.net/openid-federation-1-0-final-specification-approved/) |
| 2026-02-24 / 2026-08-11 | [RFC 10027](../rfc-sources/rfc10027.txt), Best Current Practice for Security of Cross-Device Flows (BCP 247; P. Kasselman, D. Fett, F. Skokan): approved 24 February, published 11 August. It classifies cross-device patterns and describes exploits such as device-code phishing and consent-request overload. It gives mitigations: proximity checks, short-lived or one-time codes, trusted devices and sender-constrained tokens. It also gives advice on choosing a protocol: the device grant, CIBA, or FIDO2/WebAuthn (the FIDO, Fast IDentity Online, and Web Authentication standards). | It completes the security story of RFC 8628 and CIBA. It was published after the previous vendoring and was added in this audit. | [RFC 10027](../rfc-sources/rfc10027.txt); [BCP 247](https://www.rfc-editor.org/info/bcp247); [draft history](https://datatracker.ietf.org/doc/draft-ietf-oauth-cross-device-security/) |
| 2026-04-30 to 2026-09-29 | The RFC Editor queue receives rfc7523bis-11 (30 April), status-list-20 (4 June), identity-chaining-15 (22 June), rfc8725bis-10 (25 August; blocked while it waits for the `none`/`RSA1_5` draft) and jose-hpke-encrypt-22 (29 September). The IANA OAuth Parameters registry (updated 24 August 2026) already lists values that cite rfc7523bis-11, status-list-21 and identity-chaining-16. | Treat these as future RFCs: issuer as the audience, status lists for tokens and credentials, chaining across trust domains, and the updated JWT BCP. Details in section 7. | [RFC Editor queue](https://www.rfc-editor.org/current_queue.php); [IANA OAuth Parameters](https://www.iana.org/assignments/oauth-parameters/oauth-parameters.xhtml) |
| 2026-06-04 | The IESG approves charter-ietf-oauth-06: "As automated agents increasingly act on behalf of users, organizations, or both, these delegation patterns become increasingly involved and complex." The work program: finish OAuth 2.1; complete SD-JWT, SD-JWT VC and Token Status List; mechanisms for authorizing automated agents that act for users, including across administrative domains; first-party application patterns; maintain the browser and native-app BCPs. Milestones: SD-JWT VC to the IESG by July 2026; Transaction Tokens and OAuth 2.1 by December 2026. | OAuth's current direction: delegation for non-human actors and wallets, on top of a consolidated 2.1 core. | [charter-06](https://www.ietf.org/charter/charter-ietf-oauth-06.txt); [charter history](https://datatracker.ietf.org/doc/charter-ietf-oauth/) |
| 2026-08-21 | [RFC 10017](../rfc-sources/rfc10017.txt), OAuth 2.0 for Browser-Based Applications (A. Parecki, P. De Ryck, D. Waite): approved 8 July 2025, published 21 August 2026. §4 explains that one motivation for the implicit grant was that early SPAs could not make cross-origin POST requests. It ranks three patterns: BFF (§6.1), token-mediating backend (§6.2) and browser-based OAuth client (§6.3). BCP 212 now contains RFC 8252 and RFC 10017. | It ends the story that the implicit grant started in 2012. It was published after the previous vendoring and was added in this audit. | [RFC 10017](../rfc-sources/rfc10017.txt); [BCP 212](https://www.rfc-editor.org/info/bcp212); [draft history](https://datatracker.ietf.org/doc/draft-ietf-oauth-browser-based-apps/) |
| 2026-09-03 | [OAuth 2.1 draft -16](../rfc-sources/draft-ietf-oauth-v2-1.txt): PKCE `plain` removed (`code_challenge_method` REQUIRED, S256 or a future extension, §4.1.1); `iss` REQUIRED from the AS (§4.1.2); a new Consent Phishing section (§7.9); a new Value Sizes section (§1.7.1); PAR mentioned in §3.1. Still a WG document; it expires on 7 March 2027. | Six and a half years after the first individual draft, this is the consolidated baseline to target. The repo now vendors -16, but the YAML still follows -15 in two places (section 7.1). | [draft-16](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-1-16.txt); [datatracker](https://datatracker.ietf.org/doc/draft-ietf-oauth-v2-1/) |

## 4. Why each extension exists

Each row answers two questions: what problem or attack made the document
necessary, and how the document solves it. Rows are in date order; drafts that
are not yet RFCs come last. Links go to the local copy when one exists.

Every OAuth WG RFC has a row. Eight vendored RFCs have no row, because they are
infrastructure (RFC 3986, 5646, 7617 and 9110) or small JOSE and TLS updates
(RFC 7797, 8037, 8996 and 9864). Section 6.1 says what each of them added, and
the reading path (section 8) says when to read it.

| Spec | Year | Problem or threat | How it solves it |
|---|---|---|---|
| OAuth Core 1.0 / [RFC 5849](../rfc-sources/rfc5849.txt) | 2007 / 2010 | Third-party sites asked for users' passwords and got full, unscoped access that could only be revoked by changing the password. Each provider had its own delegation API. OpenID users had no password to share. | A three-step redirect flow (temporary credentials, user authorization, token credentials; RFC 5849 §2.1-§2.3) gives each client a revocable token. Every request is signed (HMAC-SHA1 or RSA-SHA1; PLAINTEXT only over TLS) with a nonce and timestamp, so a leaked token alone is useless. |
| OAuth Core 1.0 Revision A | 2009 | Session fixation: nothing tied the user who approved to the user who completed the flow. | A signed `oauth_callback`, the `oauth_callback_confirmed` answer, and an unguessable `oauth_verifier` that the client must present to get the access token. |
| OAuth WRAP (draft-hardt-oauth-01) | 2009-2010 | OAuth 1.0 signatures were hard to implement; there were no flows for autonomous clients, rich apps or assertions; tokens were long-lived; issuing tokens was not separated from serving resources. | Short-lived bearer tokens over HTTPS from a separate authorization server, long-lived refresh tokens, and profiles per client type. It became the basic structure of OAuth 2.0. |
| [RFC 6749](../rfc-sources/rfc6749.txt) OAuth 2.0 | 2012 | Merge 1.0a and WRAP; serve web, browser, native, device and server-to-server clients; remove stored passwords, overly broad access and the lack of per-client revocation (§1). | Four roles; the code, implicit, password and client-credentials grants plus extension grants; access and refresh tokens; mandatory TLS; client types and client authentication; four IANA registries. Explicitly a framework that needs profiles (§1.8). |
| [RFC 6750](../rfc-sources/rfc6750.txt) Bearer Token Usage | 2012 | There was no standard way to present an access token to a resource server or to report token errors. | The Bearer scheme: `Authorization` header (preferred), form body, or URI query (later banned). `WWW-Authenticate` challenges with `invalid_request`, `invalid_token` or `insufficient_scope`. TLS is mandatory. |
| [RFC 6755](../rfc-sources/rfc6755.txt) URN namespace | 2012 | Extensions need globally unique identifiers for grant types, token types and assertion types. | Registers `urn:ietf:params:oauth`, as in `urn:ietf:params:oauth:grant-type:jwt-bearer`. |
| [RFC 6819](../rfc-sources/rfc6819.txt) Threat model | 2013 | The security section of RFC 6749 was short, and implementers had no systematic list of threats per component. | Assumptions, built-in security features, threats per endpoint and flow (§4) and countermeasures (§5). RFC 9700 updates it. |
| [RFC 7009](../rfc-sources/rfc7009.txt) Token Revocation | 2013 | Clients could not tell the AS that a token was no longer needed (logout, identity change, uninstall), so abandoned grants stayed valid. | An authenticated revocation endpoint that takes the token and a `token_type_hint`. Revoking a refresh token can also invalidate access tokens of the same grant. |
| [OIDC Core 1.0](../oidf-sources/oidc-core-1.0.html) (OIDF) | 2014 | OAuth 2.0 is not an authentication protocol. "Login with OAuth" implementations treated access tokens as proof of identity, which allowed token substitution and impersonation. | An ID Token (a JWT with `iss`, `sub`, `aud`, `nonce`, `auth_time`), a UserInfo endpoint, and discovery and dynamic registration on top of OAuth 2.0 flows. |
| JOSE: [RFC 7515](../rfc-sources/rfc7515.txt), [7516](../rfc-sources/rfc7516.txt), [7517](../rfc-sources/rfc7517.txt), [7518](../rfc-sources/rfc7518.txt) | 2015 | OAuth and OIDC needed compact, JSON-native integrity, confidentiality and key formats; XML signatures and the XML-based WS-\* web-services standards were too heavy for web APIs. | JWS (signatures and MACs), JWE (encryption), JWK and JWK Sets (published at `jwks_uri`), and the JWA algorithm registry, whose `none` and `RSA1_5` entries are now being deprecated. |
| [RFC 7519](../rfc-sources/rfc7519.txt) JWT | 2015 | There was no compact, URL-safe claims token for HTTP headers and query parameters, for ID Tokens, assertions and access tokens. | A claims set carried as a JWS payload or JWE plaintext, with registered claims (§4.1) and validation rules (§7.2). Updated by RFC 7797 and RFC 8725. |
| [RFC 7521](../rfc-sources/rfc7521.txt) / [7522](../rfc-sources/rfc7522.txt) / [7523](../rfc-sources/rfc7523.txt) Assertions | 2015 | Enterprises wanted to use existing SAML assertions or signed JWTs as grants, and to authenticate clients without sending a shared secret. | Assertions as grants (`grant_type` URI plus `assertion`) and as client credentials (`client_assertion_type` plus `client_assertion`). JWT client authentication is the basis of OIDC's `private_key_jwt`. |
| [RFC 7591](../rfc-sources/rfc7591.txt) Dynamic Client Registration | 2015 | Manual registration does not scale to open ecosystems, where client software meets authorization servers unknown at build time. | A registration endpoint that accepts client metadata (`redirect_uris`, `grant_types`, `token_endpoint_auth_method`, `jwks` and more), optionally vouched for by a signed software statement. |
| [RFC 7592](../rfc-sources/rfc7592.txt) Registration management | 2015 | Registered metadata changes over time, and clients sometimes need to be removed. | A client configuration endpoint protected by a registration access token (read, update, delete). Published as Experimental. |
| [RFC 7636](../rfc-sources/rfc7636.txt) PKCE | 2015 | Authorization code interception: on mobile operating systems a malicious app that registers the same custom URI scheme receives the code and redeems it. Public clients have no secret to stop this. | The client sends a `code_challenge` (the S256 hash of a fresh `code_verifier`) with the authorization request and the verifier at the token endpoint; the AS checks that they match. Later recognized as the main defense against code injection and CSRF (RFC 9700 §2.1.1, §4.5.3.1). |
| [RFC 7638](../rfc-sources/rfc7638.txt) JWK Thumbprint | 2015 | There was no stable identifier for a public key that does not depend on JSON formatting. | A hash over a canonical JSON form of the key's required members. Used as `kid`, as DPoP's `jkt`, and in RFC 9278 URIs. |
| [RFC 7662](../rfc-sources/rfc7662.txt) Token Introspection | 2015 | Resource servers that received opaque tokens could not learn their validity, scope, client or subject in a standard way. | An authenticated introspection endpoint that returns `active` plus metadata (`scope`, `client_id`, `sub`, `exp`, `aud`, `iss`, ...). |
| [RFC 7800](../rfc-sources/rfc7800.txt) PoP key semantics | 2016 | Tokens needed a standard way to say "only the holder of key K may use me". | The `cnf` (confirmation) claim with `jwk`, `jwe`, `kid` or `jku`. Reused by mTLS (`x5t#S256`) and DPoP (`jkt`). |
| [RFC 8176](../rfc-sources/rfc8176.txt) AMR values | 2017 | The OIDC `amr` claim had no standard values, which hurt interoperability for MFA (multi-factor authentication) and step-up decisions. | An IANA registry with initial values such as `pwd`, `otp`, `mfa`, `hwk` and `face`. |
| [RFC 8252](../rfc-sources/rfc8252.txt) Native apps (BCP 212) | 2017 | Embedded web-views let the host app capture credentials and cookies, bypass consent and break SSO (single sign-on); codes sent through custom schemes could be intercepted. | Native apps MUST use an external user-agent and receive responses through private-use URI schemes, claimed https URLs or loopback. Public native clients MUST use PKCE and the AS MUST support it. Updates RFC 6749 §9. |
| [RFC 8414](../rfc-sources/rfc8414.txt) AS metadata | 2018 | Clients were configured by hand for each AS, and clients that used several authorization servers could not reliably tell them apart (mix-up). | JSON metadata at `/.well-known/oauth-authorization-server`, derived from the issuer. `issuer` is REQUIRED and must be validated (§2, §3.3). |
| [RFC 8471-8473](https://www.rfc-editor.org/rfc/rfc8471.html) Token Binding | 2018 | Bearer tokens and cookies can be exported and replayed. | Key pairs at the TLS layer bind tokens to the client across connections. Chrome announced in August 2018 that it would remove its implementation, two months before the RFCs were published, so the mechanism never gained broad browser support. |
| [RFC 8628](../rfc-sources/rfc8628.txt) Device grant | 2019 | Devices with limited input or no browser (TVs, consoles, printers) cannot complete a redirect flow. | The device gets a `device_code`, a `user_code` and a `verification_uri`; the user approves on a second device; the device polls the token endpoint. §5 covers brute force and remote phishing. |
| [RFC 8693](../rfc-sources/rfc8693.txt) Token Exchange | 2020 | Services and gateways need to trade one token for another (narrower scope, other domain, delegation or impersonation). Web service clients used WS-Trust, an XML-based security token service protocol (part of the WS-\* web-services family). | A token-exchange grant with `subject_token`, `actor_token` and token-type URIs. The `act` claim expresses delegation chains. It is the basis of identity chaining and Transaction Tokens. |
| [RFC 8705](../rfc-sources/rfc8705.txt) mTLS | 2020 | Shared client secrets are weak credentials, and stolen bearer tokens can be replayed. | Client authentication with certificates over mutual TLS, and certificate-bound access tokens (`cnf.x5t#S256`) that only the holder of the private key can use. |
| [RFC 8707](../rfc-sources/rfc8707.txt) Resource Indicators | 2020 | The AS did not know where a token would be used, so it could not restrict its audience, and tokens could be replayed across resource servers. | A repeatable `resource` parameter (absolute URI) in authorization and token requests names the target resource servers. |
| [RFC 8725](../rfc-sources/rfc8725.txt) JWT BCP (BCP 225) | 2020 | Real attacks on JWT libraries: `alg: none`, `RS256`-to-`HS256` algorithm confusion, weak HMAC keys, invalid-curve attacks on `ECDH-ES` (elliptic-curve Diffie-Hellman key agreement), cross-JWT confusion and substitution. | Check the algorithm against an allow-list, use appropriate algorithms, validate `iss`, `sub` and `aud`, use explicit typing (`typ`). Its successor rfc8725bis is in the RFC Editor queue. |
| [RFC 9068](../rfc-sources/rfc9068.txt) JWT access tokens | 2021 | Vendors issued JWT access tokens with incompatible claims and validation rules; an ID Token could be replayed to an API as if it were an access token. | Header `typ` `at+jwt`, required claims (`iss`, `exp`, `aud`, `sub`, `client_id`, `iat`, `jti`), and validation rules for resource servers. |
| [RFC 9101](../rfc-sources/rfc9101.txt) JAR | 2021 | Authorization request parameters in URLs have no integrity protection, no source authentication and no confidentiality (§1), which allows attacks such as rewriting the redirect URI. | A Request Object: a signed, optionally encrypted JWT that carries the request, passed by value (`request`) or by reference (`request_uri`). |
| [RFC 9126](../rfc-sources/rfc9126.txt) PAR | 2021 | The same front-channel weaknesses, plus URL length limits and personal data leaking through query strings, logs and Referer headers. The AS could authenticate the client only at the token endpoint. | The client authenticates and POSTs the request to the PAR endpoint, then uses the short-lived `request_uri` it receives at the authorization endpoint. An AS can require PAR. |
| [RFC 9207](../rfc-sources/rfc9207.txt) Issuer identification | 2022 | Mix-up: an authorization response did not say which AS produced it. | An `iss` parameter in authorization and error responses that the client compares with the issuer it sent the request to. REQUIRED from the AS in OAuth 2.1 -16. |
| [RFC 9278](../rfc-sources/rfc9278.txt) JWK Thumbprint URI | 2022 | Some fields require URIs, for example key-derived subject identifiers in Self-Issued OpenID Provider v2. | The URI form `urn:ietf:params:oauth:jwk-thumbprint:<hash-alg>:<thumbprint>`. |
| [RFC 9396](../rfc-sources/rfc9396.txt) RAR | 2023 | Scope strings are too coarse for requests such as "please let me transfer an amount of 45 Euros to Merchant A" in open banking, e-health or signing. | `authorization_details`, a JSON array of typed objects in authorization and token requests and responses. |
| [RFC 9449](../rfc-sources/rfc9449.txt) DPoP | 2023 | Bearer tokens can be stolen and replayed. mTLS and Token Binding could not be used by browser SPAs, and audience restriction proved "prohibitively cumbersome" (§2). | The client signs a DPoP proof JWT for each request. The AS binds tokens to the key (`cnf.jkt`), public-client refresh tokens are bound too, and codes can be bound through `dpop_jkt` (§10). Bodies and headers are not signed, on purpose (§11.7). |
| [RFC 9470](../rfc-sources/rfc9470.txt) Step-up | 2023 | A resource server may need stronger or more recent user authentication than the token reflects. | An `insufficient_user_authentication` error with `acr_values` and `max_age`; `acr` and `auth_time` travel in tokens and introspection responses. |
| [RFC 9421](https://www.rfc-editor.org/rfc/rfc9421.html) HTTP Message Signatures | 2024 | After OAuth 1.0's base string and the abandoned OAuth signed-request draft, there was still no robust, general way to sign HTTP messages. | `Signature` and `Signature-Input` fields over selected, canonicalized message components. GNAP uses it. |
| [RFC 9635](https://www.rfc-editor.org/rfc/rfc9635.html) GNAP (with RFC 9767) | 2024 | Structural limits of OAuth 2.0: fixed grant types tied to browsers, a mandatory pre-registered `client_id`, bearer secrets, an overloaded `scope`. | One grant endpoint with negotiated interaction and a continuation API, client instances identified by keys, rich access requests, cryptographic proofing. Deliberately not compatible with OAuth. |
| [RFC 9700](../rfc-sources/rfc9700.txt) Security BCP (BCP 240) | 2025 | Known weaknesses were still exploited; OAuth moved into high-security uses and dynamic setups that RFC 6749 and RFC 6819 did not assume (§1). | PKCE, exact redirect URI matching, no implicit grant, no password grant, sender-constrained tokens, refresh-token protection, mix-up defenses, no open redirectors, and an explicit attacker model. Updates RFC 6749, 6750 and 6819. |
| [RFC 9701](../rfc-sources/rfc9701.txt) JWT introspection response | 2025 | Some resource servers need assurance and non-repudiation for introspection results, for example when the AS is liable for identity data used in qualified electronic signatures. | Introspection responses as signed, optionally encrypted JWTs (`application/token-introspection+jwt`). |
| [FAPI 2.0 Security Profile](https://openid.net/specs/fapi-security-profile-2_0-final.html) (OIDF) | 2025 | High-value APIs need a formally analysed, interoperable, opinionated profile of OAuth. | PAR, PKCE with S256, `iss`, confidential clients only, sender-constrained tokens, mTLS or `private_key_jwt`, the issuer as the only `aud` of client assertions, codes valid for at most 60 seconds. |
| [RFC 9728](../rfc-sources/rfc9728.txt) Protected Resource Metadata | 2025 | A client could not learn from the resource itself which AS protects it or what the resource supports. | Metadata at `/.well-known/oauth-protected-resource` (`authorization_servers`, scopes, DPoP and mTLS support) and a `resource_metadata` parameter in `WWW-Authenticate`. |
| [RFC 9901](../rfc-sources/rfc9901.txt) SD-JWT | 2025 | A holder should reveal only some claims of a credential, while the verifier can still check the issuer's signature. | Salted-hash disclosures embedded as digests in the issuer-signed JWT; the holder chooses which disclosures to send; an optional Key Binding JWT proves the holder has the key. |
| [RFC 10017](../rfc-sources/rfc10017.txt) Browser-based apps (BCP 212) | 2026 | SPAs are public clients exposed to malicious JavaScript; they inherited the implicit grant and often store tokens insecurely. | A threat analysis (§5) and three ranked architectures (BFF, token-mediating backend, browser-based client) using code + PKCE, with token-storage guidance and sender constraint. Implicit, ROPC and service-worker-only flows are discouraged. |
| [RFC 10027](../rfc-sources/rfc10027.txt) Cross-device flows (BCP 247) | 2026 | Attackers relay device codes or QR (Quick Response) codes to victims (device-code phishing, reported 2020-2021). The user cannot tell that the device that started the flow belongs to the attacker. | Patterns and exploits; practical mitigations (proximity, short-lived or one-time codes, trusted devices and networks, sender-constrained tokens, user education); protocol-selection guidance; formal-analysis results. |
| [OAuth 2.1](../rfc-sources/draft-ietf-oauth-v2-1.txt) (draft -16) | 2020-2026 (draft) | A decade of fixes was spread across RFC 6749/6750 and their errata, PKCE, the native and browser BCPs and RFC 9700, so "correct OAuth" was hard to find. | One consolidated baseline: PKCE required (S256 only since -16), exact redirect matching, no implicit and no ROPC, no bearer tokens in query strings, refresh-token constraints, `iss` REQUIRED (-16), no `redirect_uri` in the token request. |
| [draft-ietf-oauth-rfc7523bis](https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc7523bis/) (RFC Editor queue) | 2025-2026 | Audience injection: ambiguous `aud` values in JWT client authentication let a malicious AS reuse a client's assertion at an honest AS. | The AS issuer identifier is the only allowed `aud` of client-authentication JWTs, and the AS rejects anything else. Adds `typ` `client-authentication+jwt`. Updates RFC 7521, 7522, 7523 and 9126. |
| [draft-ietf-oauth-status-list](https://datatracker.ietf.org/doc/draft-ietf-oauth-status-list/) (RFC Editor queue) | 2023-2026 | Long-lived tokens and credentials (SD-JWT VC; ISO mdoc, the mobile driving licence format of ISO/IEC 18013-5) need revocation and suspension without per-token lookups that reveal the holder's activity. | A signed Status List Token (JWT or CWT, the CBOR Web Token) holds a compressed bit array; each token points to an index in it. |
| [draft-ietf-oauth-identity-chaining](https://datatracker.ietf.org/doc/draft-ietf-oauth-identity-chaining/) (RFC Editor queue) | 2023-2026 | Requests that cross trust domains lose the original user and authorization context. | Token exchange at the home AS (RFC 8693) produces a JWT grant that the other domain's AS accepts (RFC 7523); the step repeats at each boundary. |
| [draft-ietf-oauth-rfc8725bis](https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc8725bis/) (RFC Editor queue, blocked) | 2025-2026 | New JWT attacks since 2020: denial of service through the iteration count of `PBES2` (password-based encryption), JWE decompression bombs, JWT format confusion, algorithm checks that are not written defensively. | An updated BCP that obsoletes RFC 8725 and updates RFC 7519, with new threats (§2.10-§2.13) and practices (§3.13-§3.15). |
| [draft-ietf-oauth-client-id-metadata-document](https://datatracker.ietf.org/doc/draft-ietf-oauth-client-id-metadata-document/) (WG draft) | 2025-2026 | In open ecosystems such as MCP, a client must identify itself to many authorization servers without registering with each one first. | The `client_id` is an HTTPS URL that points to a client metadata document, which the AS fetches when needed. |
| [draft-ietf-oauth-transaction-tokens](https://datatracker.ietf.org/doc/draft-ietf-oauth-transaction-tokens/) (WG draft) | 2023-2026 | Inside one trust domain, user identity, workload identity and authorization context get lost along chains of microservice calls. | Short-lived Transaction Tokens carry that context through the call chain. The 2026 charter targets IESG submission by December 2026. |

## 5. Roads not taken

This section lists the abandoned approaches: the "roads not taken". OAuth's
history contains as many abandoned ideas as published ones. Each failure taught
something that the later, successful design used. The tables merge the history
research with the WG drafts that the Datatracker lists as dead or expired. Each
row says what the approach was, why it stopped, and what replaced it.

### 5.1 Abandoned protocol directions

| Approach | Period | What it was | Why it stopped | Replaced by |
|---|---|---|---|---|
| OAuth 1.1 | 2009-05 to 2010-04 | The first WG charter: evolve 1.0 into a compatible 1.1, without modifying the PLAINTEXT, HMAC-SHA1 and RSA-SHA1 methods. | WRAP's simpler bearer model, backed by engineers from Microsoft, Yahoo! and Google, won support. By April 2010 the WG had started an incompatible 2.0 from WRAP + 1.0a; charter-03 (June 2011) made it official. | OAuth 2.0 ([RFC 6749](../rfc-sources/rfc6749.txt), [RFC 6750](../rfc-sources/rfc6750.txt)); [RFC 5849](../rfc-sources/rfc5849.txt) records 1.0a. |
| Per-request signatures (signature base string) | 2007-12 to 2012-10 | Every request signed over a normalized "signature base string" with HMAC-SHA1, RSA-SHA1 or PLAINTEXT. | Normalization was error-prone (RFC 5849 §4.12; Appendix A fixes double-encoding mistakes), SHA-1 was aging (§4.11), and TLS had become cheap. Draft-06 (June 2010) removed all signatures. | Bearer tokens over TLS (RFC 6750); later sender constraint by mTLS (RFC 8705) and DPoP (RFC 9449); general HTTP signing by RFC 9421. |
| OAuth WRAP as a separate protocol | 2009-11 to 2010-04 | Short-lived bearer tokens, refresh tokens and profiles, submitted as draft-hardt-oauth-01. | Absorbed, not rejected: the IETF merged it with 1.0a instead of standardizing two protocols. The Datatracker records draft-hardt-oauth as replaced by draft-ietf-oauth-v2. | OAuth 2.0 (RFC 6749 Appendix C credits WRAP). |

### 5.2 Proof-of-possession attempts that failed

| Approach | Period | What it was | Why it stopped | Replaced by |
|---|---|---|---|---|
| MAC access tokens (draft-ietf-oauth-v2-http-mac) | 2011-01 to 2014-07 | Token type `mac`: the client proves it holds a session key by computing an HMAC over parts of each request. Last revision -05 (15 January 2014). | No WG agreement on its goals and little deployment; request normalization problems came back. The milestones were deleted on 8 May 2014 and the draft expired. | The 2014 proof-of-possession drafts, and finally [RFC 7800](../rfc-sources/rfc7800.txt), [RFC 8705](../rfc-sources/rfc8705.txt) and [RFC 9449](../rfc-sources/rfc9449.txt). |
| PoP security architecture (draft-ietf-oauth-pop-architecture) | 2014-07 to 2016-07 | An informational document that argued for proof-of-possession tokens instead of bearer tokens. It passed IETF Last Call (December 2015) but was never approved; it expired in January 2017. | Concrete mechanisms (RFC 7800, mTLS, DPoP) and the Security BCP covered the topic. | RFC 7800, RFC 8705, RFC 9449 and [RFC 9700](../rfc-sources/rfc9700.txt) §4.10. |
| PoP key distribution (draft-ietf-oauth-pop-key-distribution) | 2014-07 to 2019-03 | The AS would create and distribute PoP keys with the access token (`token_type=pop`, `cnf_req`, `rs_cnf`). | Keys created and distributed by the AS were complex. The WG moved to keys created by the client and proven at the TLS or application layer. Last revision -07 (March 2019); milestone deleted on 2 March 2021. | Client-held keys referenced through `cnf` (RFC 7800), used by DPoP and mTLS. The idea is still used for constrained devices in ACE, Authentication and Authorization for Constrained Environments ([RFC 9201](https://www.rfc-editor.org/rfc/rfc9201.html)). |
| Signed HTTP requests (draft-ietf-oauth-signed-http-request) | 2014-07 to 2016-08 | A JWS over selected request elements (method, host, path, query, headers, body hash, timestamp, token). | Stalled at -03 and expired in February 2017; milestone deleted on 2 March 2021. DPoP later chose to sign only the method, URI and token hash "to keep DPoP simple" (RFC 9449 §11.7). | DPoP for OAuth; [RFC 9421](https://www.rfc-editor.org/rfc/rfc9421.html) for general HTTP signing (used by GNAP). |
| Token Binding for OAuth (draft-ietf-oauth-token-binding) | 2016-09 to 2018-10 | Bind access tokens, refresh tokens, codes and JWT assertions to TLS Token Binding keys (RFC 8471-8473). | Chrome announced removal on 1 August 2018; without browser support there was no way to deploy it. The draft expired in April 2019; the tokbind WG closed in March 2021. | DPoP for public and browser clients; mTLS for confidential clients. |

### 5.3 Other OAuth WG drafts that died

| Draft | Period | What it was | Why it stopped | Replaced by |
|---|---|---|---|---|
| draft-ietf-oauth-authentication and draft-ietf-oauth-web-delegation | 2009-07 | A July 2009 split of draft-hammer-oauth into "The OAuth Protocol: Authentication" (signed requests) and "The OAuth Protocol: Web Delegation" (the redirect flow). | Never revised. OAuth 1.0 was published from the individual draft as RFC 5849 and the WG moved to 2.0. Marked dead on 25 August 2014. | RFC 5849; in OAuth 2.0 the authorization code grant (RFC 6749 §4.1). |
| draft-ietf-oauth-use-cases | 2012-05 to 2012-10 | A catalogue of OAuth 2.0 use cases. | "The working group lost interest in this document"; marked dead on 25 August 2014. | None (OAuth wiki). |
| draft-ietf-oauth-dyn-reg-metadata | 2014-02 to 2014-05 | Client metadata, briefly split out of the registration draft. | Merged back; its abstract now says "This specification is obsolete." | [RFC 7591](../rfc-sources/rfc7591.txt) §2. |
| draft-ietf-oauth-mix-up-mitigation | 2016-01 to 2016-07 | The AS returns `iss` and `client_id` in the authorization response so that the client can detect mix-up. | Disputed (for example over code-phishing variants) and dependent on discovery. Folded into the Security BCP; expired January 2017; its milestone was replaced on 2 March 2021 by one for the issuer in the authorization response. | RFC 8414 `issuer`, [RFC 9207](../rfc-sources/rfc9207.txt) `iss`, RFC 9700 §4.4; `iss` REQUIRED in OAuth 2.1 -16. |
| draft-ietf-oauth-closing-redirectors | 2016-02 | How an AS's error redirects can turn it into an open redirector. | Never went beyond -00; absorbed by the Security BCP. | RFC 9700 §4.11.2; OAuth 2.1 -16 §4.1.2.1 (validate `client_id` and `redirect_uri` before redirecting any error). |
| draft-ietf-oauth-incremental-authz | 2018-06 to 2020-05 | Ask for more scopes when they are needed (`include_granted_scopes`), a practice from Google. | Little uptake beyond the original deployment; expired after -04 without WG Last Call. | No IETF successor; RAR ([RFC 9396](../rfc-sources/rfc9396.txt)) and step-up ([RFC 9470](../rfc-sources/rfc9470.txt)) cover related needs. |
| draft-ietf-oauth-reciprocal | 2018-05 to 2019-08 | After party A gets a token from party B, A grants B access back without a second redirect flow. | WG Last Call opened on 6 September 2019 but never concluded; too little implementer interest; expired February 2020. | None. |
| draft-ietf-oauth-distributed | 2018-10 to 2019-04 | A 401 response with Link headers tells the client which AS protects a resource. | Revisions -00 and -01 (both 19 October 2018), then no update; expired April 2019. | [RFC 9728](../rfc-sources/rfc9728.txt) (`authorization_servers`, `resource_metadata`). |

### 5.4 Features removed or deprecated

| Feature | Period | What it was | Why it stopped | Replaced by |
|---|---|---|---|---|
| Implicit grant (`response_type=token`) | 2010 to 2025 | The access token returned in the URL fragment, for browser apps that could not make cross-origin POST requests (RFC 10017 §4). | Tokens leak through Referer headers and browser history, can be injected, and cannot be sender-constrained (RFC 9700 §2.1.2). CORS plus PKCE made the code flow workable. BCP drafts recommended against it from -09 (November 2018). | Code + PKCE (RFC 9700 §2.1.1; OAuth 2.1 §10.1; RFC 10017 §6). Excluded from the YAML on purpose. |
| Password grant (ROPC) | 2010 to 2025 | The client collects the user's password and sends it to the token endpoint (a descendant of WRAP's username/password profile). | It brings back the password anti-pattern and cannot work with MFA or WebAuthn. RFC 9700 §2.4: MUST NOT. | Code + PKCE (RFC 8252 for native apps), the device grant (RFC 8628); native first-party login is being standardized in draft-ietf-oauth-first-party-apps. Excluded from the YAML on purpose. |
| Embedded web-views for native apps | 2012 to 2017 | The login page shown inside an in-app web-view, which RFC 6749 §9 allowed. | The host app can record keystrokes, steal cookies and bypass consent; users lose SSO (RFC 8252 §8.12). | An external user-agent per [RFC 8252](../rfc-sources/rfc8252.txt) (BCP 212). |
| PKCE `plain` method | 2015-09 to 2026-09 | `code_challenge = code_verifier`, without hashing. | It exposes the verifier in the front channel and invites PKCE downgrade attacks (RFC 9700 §4.8). OAuth 2.1 -16: "Remove PKCE plain method". | S256 only (OAuth 2.1 -16 §4.1.1, §7.5.2). The YAML's enum is already S256-only, but its prose still describes `plain` as the default. |
| Bearer tokens in the URI query | 2012-10 to OAuth 2.1 | The `access_token` query parameter (RFC 6750 §2.3). | Tokens leak through logs, browser history and Referer headers (RFC 9700 §4.3.2). | The `Authorization` header or the form body only; OAuth 2.1 omits the query method. |
| `redirect_uri` in the token request | 2012-10 to OAuth 2.1 | RFC 6749 §4.1.3 required it at the token endpoint, to block code injection. | PKCE prevents code injection more robustly, so OAuth 2.1 §10.2 removed the requirement. | The PKCE `code_verifier`. |
| JOSE `none` and `RSA1_5` | 2015-05 to 2026 (in progress) | Unsecured JWS (`none`) and RSAES-PKCS1-v1_5 key encryption, that is, RSA encryption with the old padding of PKCS #1 version 1.5 (PKCS: Public-Key Cryptography Standards) (RFC 7518 §3.6, §4.2). | Libraries accepted `none` and confused algorithms (2015; RFC 8725 §2.1), and `RSA1_5` has known weaknesses. draft-ietf-jose-deprecate-none-rsa15 is at the IESG; rfc8725bis waits for it. | Allow-listed algorithms (RFC 8725 §3.1-§3.2), fully-specified algorithms ([RFC 9864](../rfc-sources/rfc9864.txt)), and `RSA-OAEP`, `ECDH-ES` or HPKE (Hybrid Public Key Encryption, in the RFC Editor queue) for encryption. |
| Token endpoint URL as client-assertion audience | 2015-05 to 2025-01 | RFC 7521 and RFC 7523 allowed the token endpoint URL or other AS identifiers as `aud` of client-authentication JWTs. | Audience injection (2025): a malicious AS could obtain assertions that an honest AS's endpoints would accept. | The issuer identifier as the only audience (rfc7523bis §4; FAPI 2.0 already requires it). |

## 6. The complete RFC timeline

### 6.1 Every RFC vendored in `../rfc-sources/`

All 50 RFCs in [`../rfc-sources/manifest.txt`](../rfc-sources/manifest.txt), in
publication order. Titles, dates and statuses come from the RFC Editor index.
36 rows are OAuth WG documents; their Status cell names no group. The other 14
rows name their source: the Datatracker group acronym (for example "jose WG"),
or "no WG" for documents published outside any working group. Each local file
is byte-identical to `https://www.rfc-editor.org/rfc/rfcNNNN.txt`. To find when
to read an RFC, search for its number in section 8.

| Date | RFC | Title | Status | What it added |
|---|---|---|---|---|
| 2005-01 | [RFC 3986](../rfc-sources/rfc3986.txt) | Uniform Resource Identifier (URI): Generic Syntax | Internet Standard (STD 66); no WG | The URI grammar behind issuer identifiers, redirect URIs, resource indicators and well-known URLs. |
| 2009-09 | [RFC 5646](../rfc-sources/rfc5646.txt) | Tags for Identifying Languages | Best Current Practice (BCP 47); ltru WG | Language-tag syntax for `ui_locales`, `claims_locales` and `*_locales_supported`. |
| 2010-04 | [RFC 5849](../rfc-sources/rfc5849.txt) | The OAuth 1.0 Protocol | Informational; no WG; obsoleted by RFC 6749 | OAuth 1.0a: the three-step redirect flow and per-request signatures (HMAC-SHA1, RSA-SHA1, PLAINTEXT) with nonce and timestamp. |
| 2012-10 | [RFC 6749](../rfc-sources/rfc6749.txt) | The OAuth 2.0 Authorization Framework | Proposed Standard | OAuth 2.0: four roles, the authorization and token endpoints, four grants, refresh tokens, client types and the IANA registries every extension uses. |
| 2012-10 | [RFC 6750](../rfc-sources/rfc6750.txt) | The OAuth 2.0 Authorization Framework: Bearer Token Usage | Proposed Standard | The Bearer token type: how to send an access token (header, body, query) and the `WWW-Authenticate` error codes. |
| 2012-10 | [RFC 6755](../rfc-sources/rfc6755.txt) | An IETF URN Sub-Namespace for OAuth | Informational | The `urn:ietf:params:oauth` namespace for grant types, token types and assertion types. |
| 2013-01 | [RFC 6819](../rfc-sources/rfc6819.txt) | OAuth 2.0 Threat Model and Security Considerations | Informational | The first systematic threat model for OAuth 2.0: threats per endpoint and flow, with countermeasures. |
| 2013-08 | [RFC 7009](../rfc-sources/rfc7009.txt) | OAuth 2.0 Token Revocation | Proposed Standard | A revocation endpoint so clients can invalidate access and refresh tokens. |
| 2015-05 | [RFC 7515](../rfc-sources/rfc7515.txt) | JSON Web Signature (JWS) | Proposed Standard; jose WG | JWS: signed or MACed JSON objects; the compact `header.payload.signature` form of every signed JWT. |
| 2015-05 | [RFC 7516](../rfc-sources/rfc7516.txt) | JSON Web Encryption (JWE) | Proposed Standard; jose WG | JWE: encrypted JSON objects for confidential tokens, request objects and responses. |
| 2015-05 | [RFC 7517](../rfc-sources/rfc7517.txt) | JSON Web Key (JWK) | Proposed Standard; jose WG | JWK and JWK Set: keys in JSON, published by an AS at `jwks_uri`. |
| 2015-05 | [RFC 7518](../rfc-sources/rfc7518.txt) | JSON Web Algorithms (JWA) | Proposed Standard; jose WG | JWA: the algorithm identifiers (`RS256`, `ES256`, `PS256`, ...) and their IANA registries. |
| 2015-05 | [RFC 7519](../rfc-sources/rfc7519.txt) | JSON Web Token (JWT) | Proposed Standard | JWT: a compact claims token with registered claims (`iss`, `sub`, `aud`, `exp`, `nbf`, `iat`, `jti`) and validation rules. |
| 2015-05 | [RFC 7521](../rfc-sources/rfc7521.txt) | Assertion Framework for OAuth 2.0 Client Authentication and Authorization Grants | Proposed Standard | Assertions as authorization grants and as client credentials (`client_assertion`). |
| 2015-05 | [RFC 7522](../rfc-sources/rfc7522.txt) | Security Assertion Markup Language (SAML) 2.0 Profile for OAuth 2.0 Client Authentication and Authorization Grants | Proposed Standard | SAML 2.0 assertions as grants and for client authentication. |
| 2015-05 | [RFC 7523](../rfc-sources/rfc7523.txt) | JSON Web Token (JWT) Profile for OAuth 2.0 Client Authentication and Authorization Grants | Proposed Standard | JWT bearer grants and JWT client authentication (the basis of `private_key_jwt`). |
| 2015-07 | [RFC 7591](../rfc-sources/rfc7591.txt) | OAuth 2.0 Dynamic Client Registration Protocol | Proposed Standard | Dynamic Client Registration: register clients at run time with JSON client metadata and software statements. |
| 2015-07 | [RFC 7592](../rfc-sources/rfc7592.txt) | OAuth 2.0 Dynamic Client Registration Management Protocol | Experimental | Read, update and delete a client registration with a registration access token. |
| 2015-09 | [RFC 7617](../rfc-sources/rfc7617.txt) | The 'Basic' HTTP Authentication Scheme | Proposed Standard; httpauth WG | The Basic HTTP authentication scheme behind `client_secret_basic`. |
| 2015-09 | [RFC 7636](../rfc-sources/rfc7636.txt) | Proof Key for Code Exchange by OAuth Public Clients | Proposed Standard | PKCE: `code_challenge` and `code_verifier` bind the authorization code to the client instance that started the flow. |
| 2015-09 | [RFC 7638](../rfc-sources/rfc7638.txt) | JSON Web Key (JWK) Thumbprint | Proposed Standard; jose WG | A canonical hash of a public key; used as DPoP `jkt` and often as `kid`. |
| 2015-10 | [RFC 7662](../rfc-sources/rfc7662.txt) | OAuth 2.0 Token Introspection | Proposed Standard | Token introspection: a resource server asks the AS whether a token is active and gets its metadata. |
| 2016-02 | [RFC 7797](../rfc-sources/rfc7797.txt) | JSON Web Signature (JWS) Unencoded Payload Option | Proposed Standard; jose WG | The JWS `b64=false` option, for large or detached payloads that do not need base64url encoding. JWTs MUST NOT use it (updates RFC 7519). |
| 2016-04 | [RFC 7800](../rfc-sources/rfc7800.txt) | Proof-of-Possession Key Semantics for JSON Web Tokens (JWTs) | Proposed Standard | The `cnf` (confirmation) claim: the key that the presenter of a token must prove it holds. |
| 2017-01 | [RFC 8037](../rfc-sources/rfc8037.txt) | CFRG Elliptic Curve Diffie-Hellman (ECDH) and Signatures in JSON Object Signing and Encryption (JOSE) | Proposed Standard; jose WG | OKP (Octet Key Pair) keys, EdDSA (Edwards-curve Digital Signature Algorithm) signatures and X25519/X448 key agreement for JOSE. The curves come from the CFRG (Crypto Forum Research Group) of the IRTF (Internet Research Task Force). |
| 2017-06 | [RFC 8176](../rfc-sources/rfc8176.txt) | Authentication Method Reference Values | Proposed Standard | The IANA registry of `amr` values (`pwd`, `otp`, `mfa`, `hwk`, ...). |
| 2017-10 | [RFC 8252](../rfc-sources/rfc8252.txt) | OAuth 2.0 for Native Apps | Best Current Practice (BCP 212) | Native apps use the system browser, PKCE and three redirect types; no embedded web-views (updates RFC 6749). |
| 2018-06 | [RFC 8414](../rfc-sources/rfc8414.txt) | OAuth 2.0 Authorization Server Metadata | Proposed Standard | AS metadata at `/.well-known/oauth-authorization-server`, anchored to the `issuer` identifier. |
| 2019-08 | [RFC 8628](../rfc-sources/rfc8628.txt) | OAuth 2.0 Device Authorization Grant | Proposed Standard | The device grant: `device_code` plus `user_code` for devices without a browser. |
| 2020-01 | [RFC 8693](../rfc-sources/rfc8693.txt) | OAuth 2.0 Token Exchange | Proposed Standard | Token exchange: the AS acts as a security token service, with delegation (`act`) or impersonation. |
| 2020-02 | [RFC 8705](../rfc-sources/rfc8705.txt) | OAuth 2.0 Mutual-TLS Client Authentication and Certificate-Bound Access Tokens | Proposed Standard | Client authentication with TLS certificates, and access tokens bound to the certificate (`cnf.x5t#S256`). |
| 2020-02 | [RFC 8707](../rfc-sources/rfc8707.txt) | Resource Indicators for OAuth 2.0 | Proposed Standard | The `resource` parameter names the target API, so the AS can restrict the token's audience. |
| 2020-02 | [RFC 8725](../rfc-sources/rfc8725.txt) | JSON Web Token Best Current Practices | Best Current Practice (BCP 225) | JWT security rules: algorithm allow-lists, explicit typing, `iss`/`aud` validation (updates RFC 7519). |
| 2021-03 | [RFC 8996](../rfc-sources/rfc8996.txt) | Deprecating TLS 1.0 and TLS 1.1 | Best Current Practice (BCP 195); tls WG | TLS 1.0 and 1.1 lack support for current cryptographic algorithms, so they must not be used; TLS 1.2 is the minimum (updates RFC 6749 and RFC 6750). |
| 2021-08 | [RFC 9101](../rfc-sources/rfc9101.txt) | The OAuth 2.0 Authorization Framework: JWT-Secured Authorization Request (JAR) | Proposed Standard | JAR: the authorization request as a signed (optionally encrypted) Request Object JWT. |
| 2021-09 | [RFC 9126](../rfc-sources/rfc9126.txt) | OAuth 2.0 Pushed Authorization Requests | Proposed Standard | PAR: the client pushes the authorization request over an authenticated back channel and gets a `request_uri`. |
| 2021-10 | [RFC 9068](../rfc-sources/rfc9068.txt) | JSON Web Token (JWT) Profile for OAuth 2.0 Access Tokens | Proposed Standard | Interoperable JWT access tokens: `typ` `at+jwt`, required claims, validation by the resource server. |
| 2022-03 | [RFC 9207](../rfc-sources/rfc9207.txt) | OAuth 2.0 Authorization Server Issuer Identification | Proposed Standard | The `iss` parameter in authorization responses, so clients can detect mix-up attacks. |
| 2022-06 | [RFC 9110](../rfc-sources/rfc9110.txt) | HTTP Semantics | Internet Standard (STD 97); httpbis WG | HTTP semantics, including the authentication framework (`WWW-Authenticate`, `Authorization`) and status codes. |
| 2022-08 | [RFC 9278](../rfc-sources/rfc9278.txt) | JWK Thumbprint URI | Proposed Standard | A URI form of RFC 7638 key thumbprints (`urn:ietf:params:oauth:jwk-thumbprint:...`). |
| 2023-05 | [RFC 9396](../rfc-sources/rfc9396.txt) | OAuth 2.0 Rich Authorization Requests | Proposed Standard | RAR: `authorization_details`, typed JSON objects for fine-grained authorization. |
| 2023-09 | [RFC 9449](../rfc-sources/rfc9449.txt) | OAuth 2.0 Demonstrating Proof of Possession (DPoP) | Proposed Standard | DPoP: a signed proof JWT on each request; tokens bound to the client key (`cnf.jkt`). |
| 2023-09 | [RFC 9470](../rfc-sources/rfc9470.txt) | OAuth 2.0 Step Up Authentication Challenge Protocol | Proposed Standard | Step-up: `insufficient_user_authentication` with `acr_values` and `max_age`. |
| 2025-01 | [RFC 9700](../rfc-sources/rfc9700.txt) | Best Current Practice for OAuth 2.0 Security | Best Current Practice (BCP 240) | The Security BCP: PKCE, exact redirect matching, no implicit or password grant, sender-constrained tokens, mix-up defenses (updates RFC 6749, 6750, 6819). |
| 2025-01 | [RFC 9701](../rfc-sources/rfc9701.txt) | JSON Web Token (JWT) Response for OAuth Token Introspection | Proposed Standard | Introspection responses as signed (optionally encrypted) JWTs. |
| 2025-04 | [RFC 9728](../rfc-sources/rfc9728.txt) | OAuth 2.0 Protected Resource Metadata | Proposed Standard | Resource metadata at `/.well-known/oauth-protected-resource` and `resource_metadata` in `WWW-Authenticate`. |
| 2025-10 | [RFC 9864](../rfc-sources/rfc9864.txt) | Fully-Specified Algorithms for JSON Object Signing and Encryption (JOSE) and CBOR Object Signing and Encryption (COSE) | Proposed Standard; jose WG | Fully-specified algorithms (`Ed25519`, `Ed448`): each identifier names one exact operation. "Polymorphic" identifiers such as `EdDSA`, which need more information (here, the key's curve), are deprecated. With `EdDSA`, metadata such as `*_alg_values_supported` cannot say which curve is supported (§1). Updates RFC 7518, RFC 8037 and RFC 9053. |
| 2025-11 | [RFC 9901](../rfc-sources/rfc9901.txt) | Selective Disclosure for JSON Web Tokens | Proposed Standard | SD-JWT: selective disclosure of JWT claims with salted digests and optional key binding. |
| 2026-08 | [RFC 10017](../rfc-sources/rfc10017.txt) | OAuth 2.0 for Browser-Based Applications | Best Current Practice (BCP 212) | Browser-based apps: BFF, token-mediating backend, or browser client with code + PKCE; implicit and password grants discouraged. |
| 2026-08 | [RFC 10027](../rfc-sources/rfc10027.txt) | Best Current Practice for Security of Cross-Device Flows | Best Current Practice (BCP 247) | Cross-device flows: threats (device-code and consent phishing) and practical mitigations. |

**Plus one Internet-Draft:**
[`draft-ietf-oauth-v2-1.txt`](../rfc-sources/draft-ietf-oauth-v2-1.txt), *The
OAuth 2.1 Authorization Framework*, revision -16 dated 3 September 2026 (a WG
document, not an RFC; see section 7.1).

**BCP numbers name sets.** BCP 212 is RFC 8252 plus RFC 10017. BCP 195 (TLS) is
RFC 8996 plus RFC 9325 and RFC 9852. BCP 47 is RFC 5646 plus RFC 4647. Cite the
RFC number when you mean one document.

**OpenID Foundation documents on the same timeline.** These are not RFCs; they
are vendored in [`../oidf-sources/`](../oidf-sources/) because the YAML models or
advertises their elements, or because RFC 9700 cites them. In the Status column,
"Final" is a finished OIDF specification, and an "Implementer's Draft" is an
approved, stable draft for early implementations.

| Date | Document | Status | Why it is here |
|---|---|---|---|
| 2014-02 (errata set 2: 2023-12-15) | [OpenID Connect Core 1.0](../oidf-sources/oidc-core-1.0.html) | Final | ID Token, UserInfo, OIDC parameters at `/authorize`. |
| 2014-02 (errata set 2: 2023-12-15) | [OpenID Connect Discovery 1.0](../oidf-sources/oidc-discovery-1.0.html) | Final | `/.well-known/openid-configuration`. |
| 2014-02 (errata set 2: 2023-12-15) | [OpenID Connect Dynamic Client Registration 1.0](../oidf-sources/openid-connect-registration-1_0.html) | Final | `registration_endpoint` and OIDC client metadata. |
| 2014-02-25 | [OAuth 2.0 Multiple Response Type Encoding Practices](../oidf-sources/oauth-v2-multiple-response-types-1_0.html) | Final | `response_mode` (`query`, `fragment`) and multi-value `response_type`. |
| 2015-04-27 | [OAuth 2.0 Form Post Response Mode](../oidf-sources/oauth-v2-form-post-response-mode-1_0.html) | Final | `response_mode=form_post`. |
| 2018-10-17 | [FAPI: JWT Secured Authorization Response Mode (JARM), Draft-02](../oidf-sources/openid-financial-api-jarm.html) | Implementer's Draft (superseded) | The edition that RFC 9700 and RFC 9207 cite. |
| 2021-09-01 | [CIBA Core 1.0](../oidf-sources/openid-client-initiated-backchannel-authentication-core-1_0.html) | Final | `backchannel_*` metadata fields. |
| 2022-09-12 | [Session Management 1.0](../oidf-sources/openid-connect-session-1_0.html) | Final | `check_session_iframe`. |
| 2022-09-12 | [RP-Initiated Logout 1.0](../oidf-sources/openid-connect-rpinitiated-1_0.html) | Final | `end_session_endpoint`. |
| 2022-09-12 | [Front-Channel Logout 1.0](../oidf-sources/openid-connect-frontchannel-1_0.html) | Final | `frontchannel_logout_*` metadata. |
| 2022-09 (errata set 1: 2023-12-15) | [Back-Channel Logout 1.0](../oidf-sources/openid-connect-backchannel-1_0.html) | Final | `backchannel_logout_*` metadata. |
| 2022-11-09 (errata set 1: 2025-08-17) | [JARM (Final)](../oidf-sources/oauth-v2-jarm.html) | Final | The current JARM text: `query.jwt`, `fragment.jwt`, `form_post.jwt`, `jwt`. |

### 6.2 OAuth outside the HTTP authorization server

These RFC families use or extend OAuth in other protocols or environments. They
are catalogued but deliberately not vendored, because an HTTP authorization
server does not implement them. Links go to rfc-editor.org.

| Family | RFCs (date) | How it relates to OAuth |
|---|---|---|
| SASL (Simple Authentication and Security Layer), kitten WG | [RFC 7628](https://www.rfc-editor.org/rfc/rfc7628.html) (2015-08) | The OAUTHBEARER mechanism lets mail and chat protocols that authenticate through SASL accept OAuth bearer tokens instead of long-term passwords. |
| Security events, secevent WG | [RFC 8417](https://www.rfc-editor.org/rfc/rfc8417.html) SET, Security Event Token (2018-07); [RFC 8935](https://www.rfc-editor.org/rfc/rfc8935.html) push delivery and [RFC 8936](https://www.rfc-editor.org/rfc/rfc8936.html) poll delivery (2020-11); [RFC 9493](https://www.rfc-editor.org/rfc/rfc9493.html) subject identifiers (2023-12); [RFC 9967](https://www.rfc-editor.org/rfc/rfc9967.html) SET profile for SCIM, the System for Cross-domain Identity Management (2026-05, scim WG) | SETs are JWTs that report events such as logout, token revocation or account compromise. The OIDC Back-Channel Logout token is SET-compatible, and the OpenID Shared Signals Framework builds on SETs. |
| ACE (Authentication and Authorization for Constrained Environments), ace WG | [RFC 9200](https://www.rfc-editor.org/rfc/rfc9200.html) ACE-OAuth (2022-08); [RFC 9201](https://www.rfc-editor.org/rfc/rfc9201.html) extra OAuth parameters, [RFC 9202](https://www.rfc-editor.org/rfc/rfc9202.html) DTLS (Datagram TLS) profile, [RFC 9203](https://www.rfc-editor.org/rfc/rfc9203.html) OSCORE (Object Security for Constrained RESTful Environments) profile, [RFC 9237](https://www.rfc-editor.org/rfc/rfc9237.html) authorization information format (all 2022-08); [RFC 9430](https://www.rfc-editor.org/rfc/rfc9430.html) TLS extension of the DTLS profile and [RFC 9431](https://www.rfc-editor.org/rfc/rfc9431.html) MQTT (Message Queuing Telemetry Transport) profile (2023-07); [RFC 9594](https://www.rfc-editor.org/rfc/rfc9594.html) group key provisioning (2024-09); [RFC 9770](https://www.rfc-editor.org/rfc/rfc9770.html) notification of revoked tokens (2025-06) | OAuth 2.0 profiled for constrained Internet of Things devices: CoAP (Constrained Application Protocol) and CBOR instead of HTTP and JSON, proof-of-possession tokens, one profile per transport security. It registers OAuth parameters, but an HTTP AS does not use it. |
| CBOR tokens, ace and cose WGs | [RFC 8392](https://www.rfc-editor.org/rfc/rfc8392.html) CWT (2018-05); [RFC 8747](https://www.rfc-editor.org/rfc/rfc8747.html) proof-of-possession for CWTs (2020-03); [RFC 9679](https://www.rfc-editor.org/rfc/rfc9679.html) COSE Key Thumbprint (2024-12) | The CBOR counterparts of JWT, `cnf` and RFC 9278 thumbprint URIs (RFC 9679 registers `urn:ietf:params:oauth:ckt`). |
| GNAP, gnap WG (closed) | [RFC 9635](https://www.rfc-editor.org/rfc/rfc9635.html) (2024-10); [RFC 9767](https://www.rfc-editor.org/rfc/rfc9767.html) resource server connections (2025-04) | A separate delegation protocol, deliberately not compatible with OAuth 2.0. Useful as a design comparison (RFC 9635 Appendix A). |
| Token Binding, tokbind WG (closed) | [RFC 8471](https://www.rfc-editor.org/rfc/rfc8471.html), [RFC 8472](https://www.rfc-editor.org/rfc/rfc8472.html), [RFC 8473](https://www.rfc-editor.org/rfc/rfc8473.html) (2018-10) | Binding tokens to TLS-layer keys. It never gained broad browser support; for OAuth, DPoP and mTLS replaced it. |
| Vectors of Trust, no WG | [RFC 8485](https://www.rfc-editor.org/rfc/rfc8485.html) (2018-10) | The `vtr` request parameter and the `vot`/`vtm` claims for multi-dimensional trust levels, registered in the OAuth and JWT registries. The YAML does not model them. |
| HTTP signing, httpbis WG | [RFC 9421](https://www.rfc-editor.org/rfc/rfc9421.html) (2024-02) | General HTTP message signatures. GNAP uses them; OAuth's sender constraint uses DPoP and mTLS instead. |
| Other protocols that accept OAuth tokens | [RFC 7635](https://www.rfc-editor.org/rfc/rfc7635.html) third-party authorization for STUN, Session Traversal Utilities for NAT (network address translation) (2015-08); [RFC 8898](https://www.rfc-editor.org/rfc/rfc8898.html) SIP, the Session Initiation Protocol (2020-09); [RFC 10006](https://www.rfc-editor.org/rfc/rfc10006.html) automatic SIP trunking (2026-08); [RFC 9725](https://www.rfc-editor.org/rfc/rfc9725.html) WHIP, the WebRTC-HTTP Ingestion Protocol (WebRTC: Web Real-Time Communication) (2025-03); [RFC 7644](https://www.rfc-editor.org/rfc/rfc7644.html) SCIM protocol (2015-09); [RFC 8620](https://www.rfc-editor.org/rfc/rfc8620.html) JMAP, the JSON Meta Application Protocol (2019-07); [RFC 7846](https://www.rfc-editor.org/rfc/rfc7846.html) peer-to-peer streaming tracker (2016-05) | These protocols let their clients present tokens issued by an AS, usually RFC 6750 bearer tokens. RFC 10006 (2026) still discusses the password grant that OAuth 2.1 removes. |
| Other consumers of OAuth and OIDC | [RFC 9560](https://www.rfc-editor.org/rfc/rfc9560.html) federated authentication for RDAP, the Registration Data Access Protocol, with OIDC (2024-04); [RFC 9509](https://www.rfc-editor.org/rfc/rfc9509.html) certificate usage for signing OAuth access tokens in 5G (fifth-generation mobile) networks (2024-03); [RFC 7853](https://www.rfc-editor.org/rfc/rfc7853.html) Globus URN namespace for scopes and extension grants (2016-05); [RFC 6616](https://www.rfc-editor.org/rfc/rfc6616.html) a SASL mechanism for OpenID 2.0 (2012-05) | They show OAuth and OIDC used as building blocks in other systems. None adds anything an HTTP AS must implement. |

Short coverage notes for these families (informational only, not a to-do list)
are in [adjacent-families](rfc-coverage-findings/adjacent-families.md) (security
events, SASL, GNAP, Token Binding, STUN, SIP and RDAP) and
[adjacent-ace](rfc-coverage-findings/adjacent-ace.md) (ACE and CBOR tokens).
Vectors of Trust is covered in
[token-exchange](rfc-coverage-findings/token-exchange.md), and RFC 9421 in
[pop](rfc-coverage-findings/pop.md).

## 7. What comes next

### 7.1 OAuth 2.1: still a draft

| Item | State on 10 October 2026 |
|---|---|
| Current revision | [draft-ietf-oauth-v2-1-16](../rfc-sources/draft-ietf-oauth-v2-1.txt), dated 3 September 2026, vendored. It expires on 7 March 2027. |
| Process state | WG document. It has not reached WG Last Call. The IESG has not reviewed it. More changes are likely. |
| Intended result | Standards Track. The abstract says that it "replaces and obsoletes" RFC 6749 and RFC 6750. |
| History | First individual draft dated 7 March 2020; WG adoption on 30 July 2020; a July 2021 target for IESG submission was missed. The June 2026 charter sets a new milestone: IESG submission by December 2026. |

**What -16 changed** (compared with -15):

- `code_challenge_method` is REQUIRED; the only defined value is S256; `plain` is
  "removed and explicitly prohibited" (§4.1.1, new §7.5.2).
- `iss` is REQUIRED in every authorization response and error redirect
  (§4.1.2, §4.1.2.1, §7.15.1). Clients may still use distinct redirect URIs as
  their mix-up defense (§7.15.2).
- A new Consent Phishing section (§7.9): per-client scope limits, developer
  verification before sensitive scopes, a clear consent screen, grant review and
  revocation.
- A new Value Sizes section (§1.7.1): no maximum lengths; receivers must not
  assume a length.
- Authorization-endpoint errors: validate `client_id` and `redirect_uri` before
  any error redirect; an error shown to the user SHOULD use HTTP 400, and HTTP
  401 does not apply (§4.1.2.1).
- PAR is mentioned in the authorization endpoint definition (§3.1); the TLS 1.3
  reference moves to RFC 9846.

**The differences from OAuth 2.0** (§10): PKCE required, exact redirect URI
matching, no implicit grant (§10.1), no password grant, no bearer tokens in query
strings, refresh-token constraints for public clients, no `redirect_uri` in the
token request (§10.2), and AS support for client credentials in the request body.

**Where this repository stands.** The vendored draft is now -16. The YAML still
follows -15 in two places. Both are confirmed HIGH findings:

- `components.parameters.CodeChallengeMethod` is `required: false`, and its
  prose says that the parameter defaults to `plain`. (Its enum is already
  `[S256]`.)
- The `/authorize` 302 response sends `iss` only when the AS advertises
  `authorization_response_iss_parameter_supported`.

See [rfc-coverage-findings/oauth21.md](rfc-coverage-findings/oauth21.md). The
older validation report
[`../rfc-validation/oauth-2.1-draft.md`](../rfc-validation/oauth-2.1-draft.md)
was written against -13.

### 7.2 The RFC Editor queue (approved, waiting for publication)

These documents are approved and are being edited for publication. Treat them as
future RFCs.

| Draft | In the queue since | Queue state | What it changes |
|---|---|---|---|
| [draft-ietf-oauth-rfc7523bis-11](https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc7523bis/) | 2026-04-30 | In progress | Updates RFC 7521, 7522, 7523 and 9126. A JWT used for client authentication must carry the AS issuer identifier as its only `aud`, and the AS must reject anything else; `typ` `client-authentication+jwt` is recommended; SAML assertions must not be used for client authentication in new applications. |
| [draft-ietf-oauth-status-list](https://datatracker.ietf.org/doc/draft-ietf-oauth-status-list/) (-20 in the queue; -21 latest) | 2026-06-04 | In progress | Token Status List: a signed, compressed bit array that says whether each JWT, SD-JWT or CWT is valid, invalid or suspended. A cacheable, privacy-friendly alternative to per-token introspection. |
| [draft-ietf-oauth-identity-chaining](https://datatracker.ietf.org/doc/draft-ietf-oauth-identity-chaining/) (-15 in the queue; -17 latest) | 2026-06-22 | In progress | Identity and authorization chaining across trust domains: token exchange at the home AS, then a JWT grant at the other domain's AS. Adds one AS metadata parameter. |
| [draft-ietf-oauth-rfc8725bis-10](https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc8725bis/) | 2026-08-25 | Blocked: waits for its normative reference draft-ietf-jose-deprecate-none-rsa15 | Second edition of the JWT BCP: obsoletes RFC 8725 and updates RFC 7519. New threats and rules: case-insensitive `alg` bypass, JWS/JWE confusion, PBES2 cost limits, JWE decompression limits, SSRF checks for `jku`, `x5u` and `jwks_uri`; `none` only on explicit opt-in. |
| [draft-ietf-jose-hpke-encrypt-22](https://datatracker.ietf.org/doc/draft-ietf-jose-hpke-encrypt/) (jose WG) | 2026-09-29 | Blocked: waits for draft-ietf-hpke-hpke | HPKE for JWE; updates RFC 7516. Relevant only if your AS encrypts tokens or accepts encrypted request objects. |

### 7.3 At the IESG (not yet in the queue)

- [draft-ietf-oauth-sd-jwt-vc-19](https://datatracker.ietf.org/doc/draft-ietf-oauth-sd-jwt-vc/):
  SD-JWT-based Verifiable Digital Credentials. State "Waiting for AD Go-Ahead".
  A credential format used by wallets; it does not change an AS.
- [draft-ietf-jose-deprecate-none-rsa15-06](https://datatracker.ietf.org/doc/draft-ietf-jose-deprecate-none-rsa15/):
  deprecates JWS `none` and JWE `RSA1_5`. State "Waiting for AD Go-Ahead" on
  9 October 2026. rfc8725bis cannot be published before it.

### 7.4 Other active OAuth WG drafts, by priority for an AS builder

| Priority | Draft | State | What it adds |
|---|---|---|---|
| Track now | [draft-ietf-oauth-security-topics-update-03](https://datatracker.ietf.org/doc/draft-ietf-oauth-security-topics-update/) | WG document | Four attacks found after RFC 9700 (audience injection, cross-toolkit account takeover, cross-user session fixation, shared consent in brokered OAuth), with countermeasures. |
| Track now | [draft-ietf-oauth-client-id-metadata-document-02](https://datatracker.ietf.org/doc/draft-ietf-oauth-client-id-metadata-document/) | WG document | `client_id` as an HTTPS URL of a metadata document; no prior registration. Used by MCP; needs a hardened outbound fetcher (SSRF rules, size limits). |
| Watch | [draft-ietf-oauth-attestation-based-client-auth-11](https://datatracker.ietf.org/doc/draft-ietf-oauth-attestation-based-client-auth/) | In WG Last Call | Client instances (mobile apps, wallets) prove that they are genuine with an attestation JWT plus proof of possession. |
| Watch | [draft-ietf-oauth-first-party-apps-04](https://datatracker.ietf.org/doc/draft-ietf-oauth-first-party-apps/) | WG consensus, waiting for write-up | An Authorization Challenge Endpoint for an operator's own native apps (browserless login). |
| Watch | [draft-ietf-oauth-transaction-tokens-11](https://datatracker.ietf.org/doc/draft-ietf-oauth-transaction-tokens/) | WG consensus, waiting for write-up | Short-lived tokens that carry user and workload context through internal call chains; charter milestone December 2026. |
| Watch | [draft-ietf-oauth-identity-assertion-authz-grant-04](https://datatracker.ietf.org/doc/draft-ietf-oauth-identity-assertion-authz-grant/) | WG document | ID-JAG (Identity Assertion JWT Authorization Grant), a profile of identity chaining for single-sign-on SaaS (software as a service) and agent scenarios. |
| Watch | [draft-ietf-oauth-refresh-token-expiration-03](https://datatracker.ietf.org/doc/draft-ietf-oauth-refresh-token-expiration/) | WG document | Token-response fields that tell clients when a refresh token and the authorization will expire. |
| Watch | [draft-ietf-oauth-rar-metadata-remediation-00](https://datatracker.ietf.org/doc/draft-ietf-oauth-rar-metadata-remediation/) | WG document | Metadata for each RAR type and a standard `insufficient_authorization` remediation from the RS. |
| Watch | [draft-ietf-oauth-deferred-token-response-00](https://datatracker.ietf.org/doc/draft-ietf-oauth-deferred-token-response/) | WG document (new) | Asynchronous completion for any grant (for example human approval), by polling or callback. |
| Watch | [draft-ietf-oauth-spiffe-client-auth-02](https://datatracker.ietf.org/doc/draft-ietf-oauth-spiffe-client-auth/) | WG document | Client authentication for workloads with SPIFFE (Secure Production Identity Framework For Everyone) identities, without shared secrets. |

### 7.5 How to keep up to date

- Run `./tools/fetch-specs.sh --check` with each manifest (runbook in
  [`../../tools/README.md`](../../tools/README.md)). It reports missing files,
  changed files and newer draft revisions.
- When a queued draft is published, add its RFC number to
  [`../rfc-sources/manifest.txt`](../rfc-sources/manifest.txt) and refresh. The
  watch list is in [`../rfc-sources/README.md`](../rfc-sources/README.md).
- After every OAuth 2.1 refresh, re-check every `OAuth 2.1 §x.y` citation in the
  YAML: section numbers shift between revisions.
- Watch the [RFC Editor queue](https://www.rfc-editor.org/current_queue.php), the
  [OAuth WG documents page](https://datatracker.ietf.org/wg/oauth/documents/) and
  the [IANA OAuth Parameters registry](https://www.iana.org/assignments/oauth-parameters/oauth-parameters.xhtml),
  which can list values from drafts before they become RFCs (today it does so
  for three drafts).

## 8. Reading path

Ten stages, 46 steps. The main document of every step is a local copy; open it
with any text viewer (RFCs) or browser (OIDF HTML). Section numbers were checked
against the local copies. "YAML" points to names in
[`../../oauth-openapi.yaml`](../../oauth-openapi.yaml); search for the name.
"Findings" points to the verified gaps for that document: the findings file of
its cluster (a group of related documents). Steps 2-6 all read RFC 6749, so its
findings file is named once, at step 4. The
[findings index](rfc-coverage-findings/README.md) lists the documents in each
cluster and the HIGH, MEDIUM and LOW counts. "Online" marks optional companions
that are not vendored.

**How to read an RFC efficiently.** Read the Introduction and the protocol
sections first. Skip the IANA Considerations unless you build a registry entry.
Always read the Security Considerations. Then find the matching YAML element and
ask: would a server generated from this YAML do what the RFC requires?

### Stage 1 — Origins (2007-2010)

Goal: understand the problem OAuth solved and the first solution.

| # | Read | Why now | Focus on |
|---|---|---|---|
| 1 | [RFC 5849](../rfc-sources/rfc5849.txt) The OAuth 1.0 Protocol | The original three-step flow and the per-request signatures that OAuth 2.0 replaced with bearer tokens. Read it to understand, not to implement. | §1 (why it is Informational), §1.2 (example), §2.1-§2.3, §3.4 (signature base string), §4.11-§4.13, Appendix A. Online: [oauth.net Introduction](https://oauth.net/about/introduction/) ("A Little Bit of History", "OAuth and OpenID"); [Advisory 2009.1](https://oauth.net/advisories/2009-1/); [OAuth Core 1.0a](https://oauth.net/core/1.0a/) §6.1.1-§6.3.1. Findings: [oauth1-origin](rfc-coverage-findings/oauth1-origin.md) maps each 1.0 element to its 2.x successor. |

### Stage 2 — OAuth 2.0 core and token lifecycle (2012-2015)

Goal: the vocabulary, the authorization code grant, and the first lifecycle
endpoints.

| # | Read | Why now | Focus on |
|---|---|---|---|
| 2 | [RFC 6749](../rfc-sources/rfc6749.txt) §1 | The vocabulary every later document uses. Compare with RFC 5849: bearer tokens, refresh tokens, a separate AS. | §1-§1.8 (note the §1.8 interoperability warning), Appendix C (acknowledgements: where 2.0 came from). YAML: the "Covered specifications" table in `info.description`. |
| 3 | RFC 6749 §2-§3 | Client types (public or confidential) drive almost every later security rule. | §2.1, §2.3, §3.1-§3.3. YAML: `ClientAuthFields`, `components.securitySchemes`. |
| 4 | RFC 6749 §4.1, §5, §6 | The authorization code grant is the one user-delegation grant OAuth 2.1 keeps. Understand it fully before any extension. | §4.1, §5.1-§5.2, §6. YAML: `paths./authorize`, `paths./token`, `AuthorizationCodeTokenRequest`, `TokenResponse`, `ErrorResponse`, `RefreshTokenRequest`. Findings: [core-6749](rfc-coverage-findings/core-6749.md). |
| 5 | RFC 6749 §4.2-§4.5, §9 | The grants that were later removed, and the extension-grant hook used by assertions, the device grant and token exchange. | §4.2 and §4.3 (historical only), §4.4, §4.5, §9. YAML: the modeling notes in `info.description`; `ClientCredentialsTokenRequest`. |
| 6 | RFC 6749 §10 | The 2012 security baseline. Read it once; RFC 6819 and RFC 9700 expand and override it. | §10.3-§10.6, §10.12 (CSRF), §10.15 (open redirectors), §10.16 (implicit impersonation). Earlier notes: [6749 validation](../rfc-validation/6749-oauth-2.0-core.md). |
| 7 | [RFC 6750](../rfc-sources/rfc6750.txt) Bearer Token Usage | How resource servers accept tokens. The bearer model is what every later proof-of-possession effort tried to fix. | §2.1 (header), §2.3 (query; later banned), §3 and §3.1 (errors), §5. YAML: `WWWAuthenticateBearerDPoP`, `securitySchemes.bearerAuth`. Findings: [bearer-http](rfc-coverage-findings/bearer-http.md). |
| 8 | [RFC 6755](../rfc-sources/rfc6755.txt) URN namespace | Short. It explains every `urn:ietf:params:oauth:...` value you will meet. | §1-§2. YAML: `TokenTypeURI` and the `grant_type` URNs on `/token`. Findings: [metadata](rfc-coverage-findings/metadata.md). |
| 9 | [RFC 6819](../rfc-sources/rfc6819.txt) Threat model | The first systematic threat catalogue. RFC 9700 §3 later makes its assumptions explicit and stronger. | §2.2, §3, §4.4, §4.6, §5. Findings: [security](rfc-coverage-findings/security.md). |
| 10 | [RFC 7009](../rfc-sources/rfc7009.txt) Token Revocation | The first lifecycle endpoint; small, and a good first extension to implement. | §2.1-§2.3, §5. YAML: `paths./revoke`, `RevocationRequest`. Findings: [revocation-introspection](rfc-coverage-findings/revocation-introspection.md). |
| 11 | [RFC 7662](../rfc-sources/rfc7662.txt) Token Introspection | The opaque-token model. Decide early whether your AS issues opaque or JWT access tokens. | §2.1-§2.2, §4, §5. YAML: `paths./introspect`, `IntrospectionResponse`. Findings: [revocation-introspection](rfc-coverage-findings/revocation-introspection.md). |

### Stage 3 — Tokens and JOSE (2015-2025)

Goal: everything a JWT is made of, and how JWTs are attacked.

| # | Read | Why now | Focus on |
|---|---|---|---|
| 12 | [RFC 7515](../rfc-sources/rfc7515.txt) JWS | Every signed artifact (ID Token, client assertion, request object, JWT access token, DPoP proof) is a JWS. | §3, §4.1 (header parameters), §5 (produce and validate), §10.6-§10.7 (algorithm validation and protection). Findings: [jose](rfc-coverage-findings/jose.md). |
| 13 | [RFC 7516](../rfc-sources/rfc7516.txt) JWE | Encrypted ID Tokens, UserInfo and introspection responses, request objects. Skim it. | §3, §5. Findings: [jose](rfc-coverage-findings/jose.md). |
| 14 | [RFC 7518](../rfc-sources/rfc7518.txt) JWA | The algorithm names in every `*_alg_values_supported` field. Note the two entries that are being deprecated in 2026. | §3.1, §3.6 (`none`), §4.1, §4.2 (`RSA1_5`), §6 (key parameters). Findings: [jose](rfc-coverage-findings/jose.md). |
| 15 | [RFC 7517](../rfc-sources/rfc7517.txt) JWK | How your AS publishes its public keys (`jwks_uri`) and how clients choose a key by `kid`. | §4, §5, §9. YAML: `paths./jwks`, `JWKS`, `JWK`. Findings: [jose](rfc-coverage-findings/jose.md) (a HIGH finding: the public key set allows a symmetric `k`). |
| 16 | [RFC 7638](../rfc-sources/rfc7638.txt), [RFC 8037](../rfc-sources/rfc8037.txt), [RFC 9864](../rfc-sources/rfc9864.txt) | Key thumbprints (used by DPoP), the OKP key type for Ed25519, and why `EdDSA` is now deprecated in favor of `Ed25519`. | RFC 7638 §3, §3.1-§3.3; RFC 8037 §2, §3.1; RFC 9864 §2.2, §4.4, §5. YAML: `Confirmation`, the `crv` values in `JWK`. Findings: [jose](rfc-coverage-findings/jose.md). |
| 17 | [RFC 7519](../rfc-sources/rfc7519.txt) JWT, with [RFC 7797](../rfc-sources/rfc7797.txt) | Claims and validation rules reused by OIDC, assertions and JWT access tokens. RFC 7797 adds one rule for JWTs: never `b64=false`. | RFC 7519 §4.1, §5, §6 (unsecured JWTs, a historical risk), §7.2; RFC 7797 §3, §6. YAML: `JWT`, `NumericDate`. Findings: [jwt](rfc-coverage-findings/jwt.md). |
| 18 | [RFC 8725](../rfc-sources/rfc8725.txt) JWT BCP | Before you issue or validate any JWT: the known attacks and the required defenses. | §2.1-§2.9, §3.1, §3.2, §3.8-§3.12. Online: [rfc8725bis-10](https://www.ietf.org/archive/id/draft-ietf-oauth-rfc8725bis-10.txt) §2.10-§2.13, §3.13-§3.15 (the new sections; in the RFC Editor queue). Findings: [jwt](rfc-coverage-findings/jwt.md). |
| 19 | [RFC 9068](../rfc-sources/rfc9068.txt) JWT access tokens | If your AS issues self-contained access tokens, this is the interoperable format (`typ` `at+jwt`). | §2.1-§2.2, §3, §4, §5. YAML: `JWTAccessTokenClaims`. Findings: [jwt-at-sdjwt](rfc-coverage-findings/jwt-at-sdjwt.md). |
| 20 | [RFC 9701](../rfc-sources/rfc9701.txt) JWT introspection responses | Signed introspection for resource servers that need proof of origin. It builds on step 11. | §4, §5, §8.1-§8.2. YAML: `JWTIntrospectionResponse`. Findings: [revocation-introspection](rfc-coverage-findings/revocation-introspection.md). |

### Stage 4 — OpenID Connect (2014-2022)

Goal: the identity layer. RFC 9700 and OAuth 2.1 assume that you know the ID
Token and `nonce`, and OIDC is where discovery and registration started.

| # | Read | Why now | Focus on |
|---|---|---|---|
| 21 | [OpenID Connect Core 1.0](../oidf-sources/oidc-core-1.0.html) | OAuth is delegation; OIDC adds authentication. Learn the ID Token and `nonce` now. | §2, §3.1 (especially §3.1.2.1 and §3.1.3.7), §5.3, §9, §16. YAML: `paths./userinfo`, `IDTokenClaims`. Findings: [oidc](rfc-coverage-findings/oidc.md). |
| 22 | [OIDC Discovery 1.0](../oidf-sources/oidc-discovery-1.0.html), [Multiple Response Types](../oidf-sources/oauth-v2-multiple-response-types-1_0.html), [Form Post Response Mode](../oidf-sources/oauth-v2-form-post-response-mode-1_0.html) | Discovery came back to OAuth through OIDC; `response_mode=form_post` keeps codes and tokens out of URLs. | Discovery §3-§4; Multiple Response Types §2-§3, §5; Form Post §2. YAML: `paths./.well-known/openid-configuration`, `OpenIDProviderMetadata`, `ResponseMode`. Findings: [oidc](rfc-coverage-findings/oidc.md). |
| 23 | [JARM (Final)](../oidf-sources/oauth-v2-jarm.html) | Signed authorization responses: a defense against mix-up and code injection. RFC 9700 and RFC 9207 cite the [2018 draft](../oidf-sources/openid-financial-api-jarm.html); model against the Final text. | §2 (§2.1-§2.4), §5. Findings: [oidc](rfc-coverage-findings/oidc.md). |

### Stage 5 — Hardening the code flow (2015-2022)

Goal: protect the authorization code and the front channel.

| # | Read | Why now | Focus on |
|---|---|---|---|
| 24 | [RFC 7636](../rfc-sources/rfc7636.txt) PKCE | The most important extension after 2012 and mandatory in OAuth 2.1. Read the attack in §1 first. | §1, §4.1-§4.6, §7.1-§7.2. YAML: `CodeChallenge`, `CodeChallengeMethod` (still -15 text). Earlier notes: [7636 validation](../rfc-validation/7636-pkce.md); findings: [pkce-apps](rfc-coverage-findings/pkce-apps.md). |
| 25 | [RFC 8252](../rfc-sources/rfc8252.txt) Native apps (BCP 212) | The first BCP that overrides RFC 6749: system browser plus PKCE for mobile and desktop clients. | §4-§7 (§7.1 private-use schemes, §7.2 claimed https, §7.3 loopback), §8.1, §8.4, §8.10, §8.12. Findings: [pkce-apps](rfc-coverage-findings/pkce-apps.md) (a HIGH finding: the YAML requires exact redirect matching without the loopback-port exception of §7.3). |
| 26 | [RFC 9700](../rfc-sources/rfc9700.txt) §4.4, then [RFC 9207](../rfc-sources/rfc9207.txt) | The mix-up attack (2016) and its one-parameter fix. This explains why issuer identifiers appear everywhere. | RFC 9700 §4.4.1-§4.4.2; RFC 9207 §2, §2.3-§2.4, §3, §4. Online: [arXiv:1601.01229](https://arxiv.org/abs/1601.01229); [WG advisory](https://mailarchive.ietf.org/arch/msg/oauth/JIVxFBGsJBVtm7ljwJhPUm3Fr-w/). YAML: the `/authorize` 302 description; `authorization_response_iss_parameter_supported`. Findings: [security](rfc-coverage-findings/security.md) (RFC 9700), [jar-par-iss](rfc-coverage-findings/jar-par-iss.md) (RFC 9207). |
| 27 | [RFC 9101](../rfc-sources/rfc9101.txt) JAR | Request parameters inside a signed object: integrity and source authentication for the front channel. | §1 (weaknesses a-c), §4, §5.1-§5.2, §6, §10. YAML: `parameters.Request`, `RequestUri`. Findings: [jar-par-iss](rfc-coverage-findings/jar-par-iss.md). |
| 28 | [RFC 9126](../rfc-sources/rfc9126.txt) PAR | Push the request over an authenticated back channel. Required by FAPI 2.0 and mentioned in OAuth 2.1 -16 §3.1. | §1, §2.1-§2.3, §3, §4, §5, §7.1. YAML: `paths./par`, `PARRequest`, `PARResponse`. Findings: [jar-par-iss](rfc-coverage-findings/jar-par-iss.md) (a HIGH finding: the required fields of `PARRequest` block a pushed JAR Request Object). |

### Stage 6 — Discovery and registration (2015-2025)

Goal: how clients, authorization servers and resources find each other.

| # | Read | Why now | Focus on |
|---|---|---|---|
| 29 | [RFC 8414](../rfc-sources/rfc8414.txt) AS metadata | The discovery document your AS must publish. Its `issuer` anchors the mix-up and audience-injection fixes. | §2, §3, §3.3, §6.2. YAML: `paths./.well-known/oauth-authorization-server`, `OAuthServerMetadata`. Earlier notes: [8414 validation](../rfc-validation/8414-as-metadata.md); findings: [metadata](rfc-coverage-findings/metadata.md). |
| 30 | [RFC 7591](../rfc-sources/rfc7591.txt), [RFC 7592](../rfc-sources/rfc7592.txt), [OIDC Registration 1.0](../oidf-sources/openid-connect-registration-1_0.html) | Clients registered at run time. This is also the setting in which an attacker can run an AS that your clients talk to. | RFC 7591 §2, §2.3, §3, §5; RFC 7592 §2; OIDC Registration §2-§3. YAML: only `registration_endpoint`; there is no `/register` path yet. Findings: [dcr](rfc-coverage-findings/dcr.md) (6 HIGH findings). |
| 31 | [RFC 9728](../rfc-sources/rfc9728.txt) Protected Resource Metadata | It completes discovery (client, AS, resource). MCP made it mandatory in 2025. | §2, §3, §3.3, §5, §5.1, §7.3, §7.7 (SSRF). YAML: `paths./.well-known/oauth-protected-resource`, `ProtectedResourceMetadata`. Findings: [metadata](rfc-coverage-findings/metadata.md). |

### Stage 7 — Advanced grants and fine-grained authorization (2015-2023)

Goal: grants beyond the browser redirect, and authorization beyond scope strings.

| # | Read | Why now | Focus on |
|---|---|---|---|
| 32 | [RFC 7521](../rfc-sources/rfc7521.txt) and [RFC 7523](../rfc-sources/rfc7523.txt) (and [RFC 7522](../rfc-sources/rfc7522.txt)) | Assertion grants and `private_key_jwt`. Then read the 2025 fix to see how a loose audience rule became an attack. | RFC 7521 §4.1-§4.2, §5.1-§5.2, §8; RFC 7523 §2.1-§2.2, §3. Online: [rfc7523bis-11](https://www.ietf.org/archive/id/draft-ietf-oauth-rfc7523bis-11.txt) §1, §4. YAML: `ClientAuthFields`, `JWTBearerTokenRequest`. Findings: [assertions](rfc-coverage-findings/assertions.md) (HIGH: `JWTBearerTokenRequest` has no client-authentication fields). |
| 33 | [RFC 8628](../rfc-sources/rfc8628.txt) Device grant, with [CIBA Core](../oidf-sources/openid-client-initiated-backchannel-authentication-core-1_0.html) | Devices without a browser. Read §5.4 now; RFC 10027 (step 44) expands it. CIBA is the other cross-device protocol. | RFC 8628 §3.1-§3.5, §5.1-§5.4; CIBA §5, §7, §10. YAML: `paths./device_authorization`, `DeviceAuthorizationRequest`, `DeviceAuthorizationResponse`, `DeviceCodeTokenRequest`. Findings: [device-crossdevice](rfc-coverage-findings/device-crossdevice.md); for CIBA, [oidc](rfc-coverage-findings/oidc.md). |
| 34 | [RFC 8693](../rfc-sources/rfc8693.txt) Token Exchange | Delegation between services, and the base of 2026's agent and cross-domain work (identity chaining, Transaction Tokens). | §1.1, §2.1-§2.2, §3, §4.1, §4.4. YAML: `TokenExchangeRequest`, `TokenTypeURI`. Findings: [token-exchange](rfc-coverage-findings/token-exchange.md). |
| 35 | [RFC 8707](../rfc-sources/rfc8707.txt) Resource Indicators | Audience restriction for access tokens; it pairs with RFC 9728. | §2.1-§2.2, §3. YAML: `parameters.Resource`, `ResourceIndicators`. Findings: [resource-rar-stepup](rfc-coverage-findings/resource-rar-stepup.md). |
| 36 | [RFC 9396](../rfc-sources/rfc9396.txt) RAR | Consent beyond scope strings (payments, e-health). Also a design input to GNAP. | §2, §3.1-§3.2, §6-§7, §9. YAML: `parameters.AuthorizationDetails`, `AuthorizationDetail`. Findings: [resource-rar-stepup](rfc-coverage-findings/resource-rar-stepup.md). |
| 37 | [RFC 9470](../rfc-sources/rfc9470.txt) Step-up, with [RFC 8176](../rfc-sources/rfc8176.txt) | How a resource server asks for stronger or more recent user authentication; it connects OAuth with the OIDC `acr` and `amr` claims. | RFC 9470 §3-§6; RFC 8176 §2-§3. YAML: the `WWW-Authenticate` examples in `components.headers`. Findings: [resource-rar-stepup](rfc-coverage-findings/resource-rar-stepup.md) (RFC 9470), [token-exchange](rfc-coverage-findings/token-exchange.md) (RFC 8176). |

### Stage 8 — Sender-constrained tokens (2016-2023)

Goal: make a stolen token useless.

| # | Read | Why now | Focus on |
|---|---|---|---|
| 38 | [RFC 7800](../rfc-sources/rfc7800.txt) `cnf` claim | The place in a token that names the key. Both mTLS and DPoP reuse it. | §3 (§3.1-§3.5). YAML: `Confirmation`. Findings: [pop](rfc-coverage-findings/pop.md). |
| 39 | [RFC 8705](../rfc-sources/rfc8705.txt) mTLS | The first standard sender constraint for OAuth tokens, and one of the two options in FAPI 2.0. It also works for public clients, which use self-signed certificates (§4). | §2.1-§2.2, §3, §3.1, §4, §6.5, §7.1. YAML: `securitySchemes.mtls`, `tls_client_certificate_bound_access_tokens`. Findings: [pop](rfc-coverage-findings/pop.md). |
| 40 | [RFC 9449](../rfc-sources/rfc9449.txt) DPoP, with [RFC 9278](../rfc-sources/rfc9278.txt) | Sender constraint for public clients: the end of the 13-year proof-of-possession story. | RFC 9449 §1-§2 (why), §4.2-§4.3, §5, §6.1, §7.1-§7.2, §8, §10, §11.7; RFC 9278 §1, §3. YAML: `DPoPHeader`, `DPoPJKT`, `headers.DPoPNonce`, `securitySchemes.dpop`. Earlier notes: [9449 validation](../rfc-validation/9449-dpop.md); findings: [pop](rfc-coverage-findings/pop.md). |

### Stage 9 — Modern security BCPs (2021-2026)

Goal: the current rules, after you know every mechanism they refer to.

| # | Read | Why now | Focus on |
|---|---|---|---|
| 41 | [RFC 8996](../rfc-sources/rfc8996.txt) TLS 1.0 and 1.1 deprecated | Short. TLS 1.0 and 1.1 lack current cryptographic algorithms. RFC 8996 formally updates RFC 6749 and RFC 6750: TLS 1.2 is the minimum. BCP 195 also holds [RFC 9325](https://www.rfc-editor.org/rfc/rfc9325.html) (deploying TLS securely) and, since July 2026, [RFC 9852](https://www.rfc-editor.org/rfc/rfc9852.html) (new protocols must default to TLS 1.3). | §1.1, §4, §5. Findings: [bearer-http](rfc-coverage-findings/bearer-http.md). |
| 42 | [RFC 9700](../rfc-sources/rfc9700.txt) Security BCP (BCP 240) | The normative baseline. Read it after the mechanisms, so each rule points to something you already know. | §1, §2 (all), §3, §4.1-§4.3, §4.5, §4.7-§4.8, §4.10-§4.12, §4.14, §4.16-§4.17. Online: [FAPI 2.0 Security Profile](https://openid.net/specs/fapi-security-profile-2_0-final.html) §5.1.1, §5.2, §5.3.2-§5.3.3 (ready-made defaults). Earlier notes: [9700 validation](../rfc-validation/9700-security-bcp.md); findings: [security](rfc-coverage-findings/security.md). |
| 43 | [RFC 10017](../rfc-sources/rfc10017.txt) Browser-based apps (BCP 212) | It ends the story that the implicit grant started. Read it together with RFC 8252: the two form BCP 212. | §4, §5, §6.1 (BFF), §6.2, §6.3 (including §6.3.2.3 refresh tokens and §6.3.3.4 cross-origin requests), §7.2, §8, §9. Findings: [pkce-apps](rfc-coverage-findings/pkce-apps.md). |
| 44 | [RFC 10027](../rfc-sources/rfc10027.txt) Cross-device flows (BCP 247) | The phishing problems of the device grant, QR codes and CIBA, which RFC 8628 mentioned only briefly (§5.4). | §1, §2, §3.1, §4, §6.1, §6.2, §6.3 (formal analysis). Findings: [device-crossdevice](rfc-coverage-findings/device-crossdevice.md). |

### Stage 10 — OAuth 2.1 and beyond (2020-2026)

Goal: the consolidated target, and where the WG is going.

| # | Read | Why now | Focus on |
|---|---|---|---|
| 45 | [OAuth 2.1, draft -16](../rfc-sources/draft-ietf-oauth-v2-1.txt) | The consolidated target for your AS. Read it last, so each change listed in §10 makes sense. | §10 (§10.1, §10.2), §1.7.1, §4.1.1, §4.1.2-§4.1.2.1, §7 (note §7.5.2 and §7.9), Appendix F (document history, including -16). Findings: [oauth21](rfc-coverage-findings/oauth21.md); earlier notes: [oauth-2.1-draft.md](../rfc-validation/oauth-2.1-draft.md) (written against -13). |
| 46 | [RFC 9901](../rfc-sources/rfc9901.txt) SD-JWT | Where the 2026 charter is heading: digital credentials (issuer, holder, verifier). Outside the AS HTTP surface. | §1-§4, §7. Online: [status-list-21](https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-21.txt); [SD-JWT VC](https://datatracker.ietf.org/doc/draft-ietf-oauth-sd-jwt-vc/). Findings: [jwt-at-sdjwt](rfc-coverage-findings/jwt-at-sdjwt.md). |

### After the path: follow online

- [RFC 9635](https://www.rfc-editor.org/rfc/rfc9635.html) GNAP §1, §2, §7 and
  Appendix A: compare OAuth with a completely new design before you decide your
  roadmap.
- [charter-ietf-oauth-06](https://www.ietf.org/charter/charter-ietf-oauth-06.txt),
  "Work Program": where the WG is going (automated agents, credentials).
- [draft-ietf-oauth-security-topics-update](https://datatracker.ietf.org/doc/draft-ietf-oauth-security-topics-update/)
  §2.1-§2.4: the newest attacks.
- The drafts in section 7.

### Reference shelf (read a section when the YAML cites it)

| Document | When you need it |
|---|---|
| [RFC 3986](../rfc-sources/rfc3986.txt) URI syntax | Rules for issuer identifiers, redirect URIs and resource indicators. Findings: [metadata](rfc-coverage-findings/metadata.md). |
| [RFC 5646](../rfc-sources/rfc5646.txt) BCP 47 language tags | `ui_locales`, `claims_locales`, `*_locales_supported`. |
| [RFC 7617](../rfc-sources/rfc7617.txt) Basic scheme | `client_secret_basic` (OAuth 2.1 §2.4.1: form-urlencode the ID and secret first). Findings: [bearer-http](rfc-coverage-findings/bearer-http.md). |
| [RFC 9110](../rfc-sources/rfc9110.txt) HTTP Semantics | §11 (authentication framework) and §15 (status codes). Findings: [bearer-http](rfc-coverage-findings/bearer-http.md). |
| [Session Management](../oidf-sources/openid-connect-session-1_0.html), [RP-Initiated Logout](../oidf-sources/openid-connect-rpinitiated-1_0.html), [Front-Channel Logout](../oidf-sources/openid-connect-frontchannel-1_0.html), [Back-Channel Logout](../oidf-sources/openid-connect-backchannel-1_0.html) | The session and logout metadata fields that `OAuthServerMetadata` advertises. Findings: [oidc](rfc-coverage-findings/oidc.md). |

## 9. Key lessons

Sixteen design lessons from twenty years of OAuth, each with what it means for a
new authorization server.

1. **Delegation is not authentication.** OAuth was designed in 2007 for API
   delegation and kept separate from OpenID. RFC 6749 §10.16 already warned that
   access tokens are misused as proof of identity. Identity came from OpenID
   Connect (2014): an ID Token with `aud` and `nonce`. Issue identity only under
   OIDC rules, and never let clients treat an access token as login evidence.
2. **Bearer tokens made OAuth easy to adopt; key binding had to come back
   later.** OAuth 1.0 signed every request, but its signature base string was
   fragile (RFC 5849 §4.12). OAuth 2.0 draft -06 (June 2010) removed all
   signatures. MAC tokens (2011-2014), the PoP drafts (2014-2019) and Token
   Binding (2016-2018) failed. mTLS (2020) and DPoP (2023) succeeded because they
   are easy to deploy; DPoP signs only the method, URI and token hash, on purpose
   (RFC 9449 §11.7). RFC 9700 §2.2.1 now says that access tokens SHOULD be
   sender-constrained.
3. **The browser front channel is hostile.** Anything in a browser URL can leak
   (Referer headers, history, logs: RFC 9700 §4.2-§4.3) or be injected
   (§4.5-§4.6). The answers: no tokens in authorization responses (implicit
   removed), parameters in signed or back-channel requests (JAR, PAR), codes bound
   to the client that started the flow (PKCE), and the `form_post` or JARM
   response modes.
4. **Bind every multi-step flow to whoever started it.** The same lesson was
   learned four times: session fixation in 2009 (fixed with `oauth_verifier`),
   CSRF in 2.0 (`state`), code interception and injection (PKCE; RFC 9700 §2.1.1
   notes that it also stops CSRF), and binding the code to a key (DPoP
   `dpop_jkt`, RFC 9449 §10). RFC 10027 extends the idea to flows across two
   devices.
5. **Name the issuer and the audience explicitly.** Mix-up (2016) happened
   because responses did not say who issued them. The fix: the RFC 8414
   `issuer`, the RFC 9207 `iss` parameter, and `iss` REQUIRED in OAuth 2.1 -16.
   Audience injection (2025) happened because `aud` could be any endpoint URL.
   The fix: the issuer as the only audience in rfc7523bis, which FAPI 2.0 already
   requires. Explicit JWT typing (RFC 8725 §3.11) prevents confusion between kinds
   of JWT.
6. **Dynamic trust needs a stronger attacker model.** RFC 9700 §1 notes that
   OAuth first assumed static relationships between client, AS and RS. Dynamic
   registration (RFC 7591), metadata (RFC 8414, RFC 9728), OpenID Federation
   (2026) and Client ID Metadata Documents made attacker-operated servers
   realistic (RFC 9700 §3). Validate metadata issuers (RFC 8414 §3.3) and guard
   against SSRF when you fetch metadata (RFC 9728 §7.7).
7. **A framework needs profiles.** RFC 6749 §1.8 says that it is "likely to
   produce a wide range of non-interoperable implementations", and the 2012
   resignation post said the same more strongly. The answer was profiles and
   BCPs: OIDC, FAPI 2.0, OAuth 2.1, and BCPs 212, 225, 240 and 247. For a new AS,
   choose a profile (OAuth 2.1 + RFC 9700 + FAPI-2.0-style defaults) and make it
   the default behavior, not an option.
8. **Formal analysis finds what expert review misses.** Mix-up (2016), the FAPI
   analysis (2019) and audience injection (2025) were specification bugs found by
   modeling, not implementation bugs. RFC 10027 §6.3 explains the strengths and
   limits of the method. Follow the OAuth Security Workshop and
   draft-ietf-oauth-security-topics-update.
9. **Security guidance moves faster than RFC numbers.** A BCP draft discouraged
   the implicit grant in November 2018, but RFC 9700 appeared only in January
   2025. OAuth 2.1 started in 2020 and is still a draft. RFC 10017 waited 13
   months between approval and publication. JAR took 11 years from first draft to
   RFC, and protected resource metadata about nine. Track WG drafts, the RFC
   Editor queue and IANA entries that already cite drafts, not only published
   RFCs.
10. **Platform support decides whether a protocol survives.** Token Binding was
    standardized (RFC 8471-8473, October 2018), but two months earlier Chrome had
    announced that it would remove its implementation, so it never gained broad
    browser support.
    DPoP works with WebCrypto keys, the BFF pattern (RFC 10017) works in today's
    browsers, and MCP's adoption in 2025 showed that ecosystems deploy drafts
    that are easy to implement.
11. **Public clients cannot keep secrets; design around that.** PKCE is a secret
    for one flow; native apps use the system browser (RFC 8252); SPAs use a BFF,
    a token-mediating backend or a browser-based client with DPoP (RFC 10017
    §6); public-client refresh tokens are sender-constrained or rotated (RFC
    9700 §2.2.2). For app integrity,
    see draft-ietf-oauth-attestation-based-client-auth.
12. **Token format is a trade-off.** Opaque tokens with introspection (RFC 7662,
    RFC 9701) give fresh status and revocation. JWT access tokens (RFC 9068) allow
    local validation but need the RFC 8725 rules (algorithm allow-lists, `typ`
    `at+jwt`, `aud` checks) and short lifetimes. Expiring tokens plus refresh
    tokens are the cost of self-contained tokens. Token Status List brings
    revocation back for long-lived credentials.
13. **Scope alone is too coarse; say where and what.** Use resource indicators
    for the audience (RFC 8707), `authorization_details` for structured requests
    (RFC 9396) and step-up challenges (RFC 9470). RFC 9449 §2 notes that audience
    restriction proved "prohibitively cumbersome" in practice, which is why sender
    constraint complements it.
14. **Users are part of the attack surface.** RFC 8628 §5.4 warned about remote
    phishing; device-code phishing campaigns (2020-2021) led to RFC 10027. OAuth
    2.1 -16 adds a consent-phishing section (§7.9), and the RFC 9700 update draft
    covers shared consent in brokered OAuth. Consent screens, user codes and QR
    flows need anti-phishing design, not only a correct protocol.
15. **Evolve; rewrite only rarely.** The rewrite from 1.1 to 2.0 caused a public
    split and years of drafting. GNAP (RFC 9635) is a completely new design, but
    it expects to coexist with OAuth. The June 2026 charter chose consolidation (OAuth 2.1)
    plus extensions instead of a migration.
16. **The next delegation problem is non-human actors.** The 2026 charter
    targets automated agents that act for users, also across domains. Token
    Exchange (RFC 8693), identity chaining, Transaction Tokens, the IETF WIMSE
    working group (Workload Identity in a Multi System Environment) and MCP's
    use of OAuth 2.1, RFC 9728 and Client ID Metadata Documents show the
    direction. Plan for token exchange with
    `act` and `may_act`, protected resource metadata and URL-based client
    identifiers from the start.

## 10. Sources

### Method

The research combined three kinds of evidence. **(1) Primary records,
downloaded on 10 October 2026:** the RFC Editor index (all 9,847 RFCs), the
Datatracker states of every active OAuth WG draft, the RFC Editor queue, the IANA
registries for OAuth parameters, JWT, JOSE, well-known URIs and HTTP
authentication schemes, and the OpenID Foundation specifications. **(2) Historical
records:** IETF charters, meeting minutes, archived drafts, mailing-list posts,
oauth.net pages and the other URLs below. **(3) A document-by-document comparison
of [`../../oauth-openapi.yaml`](../../oauth-openapi.yaml) with each vendored
text.** The work used parallel research and coverage agents; every coverage claim
was then checked by an independent, adversarial verifier that tried to refute it
against the YAML and the source text (724 findings survived; see
[rfc-coverage-findings/README.md](rfc-coverage-findings/README.md)). Every
historical event in section 3 was verified against at least one primary source
listed below; no unverified claim is used. All 50 vendored RFC files are
byte-identical to `https://www.rfc-editor.org/rfc/rfcNNNN.txt`, and the 12 OIDF
files to their openid.net URLs (checked on 11 October 2026).

### Sources (deduplicated)

- **Data sets:**
  [IANA HTTP Authentication Schemes](https://www.iana.org/assignments/http-authschemes/http-authschemes.xhtml) · [IANA JOSE](https://www.iana.org/assignments/jose/jose.xhtml) · [IANA JSON Web Token Claims](https://www.iana.org/assignments/jwt/jwt.xhtml) · [IANA OAuth Parameters](https://www.iana.org/assignments/oauth-parameters/oauth-parameters.xhtml)
  [IANA Well-Known URIs](https://www.iana.org/assignments/well-known-uris/well-known-uris.xhtml) · [OAuth WG documents](https://datatracker.ietf.org/wg/oauth/documents/) · [RFC Editor index](https://www.rfc-editor.org/rfc-index.xml) · [RFC Editor queue](https://www.rfc-editor.org/current_queue.php)
- **RFC Editor, RFCs used for the history and the timeline:**
  [RFC 5849](https://www.rfc-editor.org/rfc/rfc5849.html) · [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html) · [RFC 6750](https://www.rfc-editor.org/rfc/rfc6750.html) · [RFC 6755](https://www.rfc-editor.org/rfc/rfc6755.html) · [RFC 6819](https://www.rfc-editor.org/rfc/rfc6819.html) · [RFC 7009](https://www.rfc-editor.org/rfc/rfc7009.html) · [RFC 7515](https://www.rfc-editor.org/rfc/rfc7515.html) · [RFC 7516](https://www.rfc-editor.org/rfc/rfc7516.html)
  [RFC 7517](https://www.rfc-editor.org/rfc/rfc7517.html) · [RFC 7518](https://www.rfc-editor.org/rfc/rfc7518.html) · [RFC 7519](https://www.rfc-editor.org/rfc/rfc7519.html) · [RFC 7521](https://www.rfc-editor.org/rfc/rfc7521.html) · [RFC 7591](https://www.rfc-editor.org/rfc/rfc7591.html) · [RFC 7592](https://www.rfc-editor.org/rfc/rfc7592.html) · [RFC 7636](https://www.rfc-editor.org/rfc/rfc7636.html) · [RFC 7638](https://www.rfc-editor.org/rfc/rfc7638.html)
  [RFC 7662](https://www.rfc-editor.org/rfc/rfc7662.html) · [RFC 8252](https://www.rfc-editor.org/rfc/rfc8252.html) · [RFC 8414](https://www.rfc-editor.org/rfc/rfc8414.html) · [RFC 8471](https://www.rfc-editor.org/rfc/rfc8471.html) · [RFC 8628](https://www.rfc-editor.org/rfc/rfc8628.html) · [RFC 8693](https://www.rfc-editor.org/rfc/rfc8693.html) · [RFC 8705](https://www.rfc-editor.org/rfc/rfc8705.html) · [RFC 8707](https://www.rfc-editor.org/rfc/rfc8707.html)
  [RFC 8725](https://www.rfc-editor.org/rfc/rfc8725.html) · [RFC 9068](https://www.rfc-editor.org/rfc/rfc9068.html) · [RFC 9101](https://www.rfc-editor.org/rfc/rfc9101.html) · [RFC 9126](https://www.rfc-editor.org/rfc/rfc9126.html) · [RFC 9207](https://www.rfc-editor.org/rfc/rfc9207.html) · [RFC 9278](https://www.rfc-editor.org/rfc/rfc9278.html) · [RFC 9396](https://www.rfc-editor.org/rfc/rfc9396.html) · [RFC 9421](https://www.rfc-editor.org/rfc/rfc9421.html)
  [RFC 9449](https://www.rfc-editor.org/rfc/rfc9449.html) · [RFC 9470](https://www.rfc-editor.org/rfc/rfc9470.html) · [RFC 9635](https://www.rfc-editor.org/rfc/rfc9635.html) · [RFC 9700](https://www.rfc-editor.org/rfc/rfc9700.html) · [RFC 9701](https://www.rfc-editor.org/rfc/rfc9701.html) · [RFC 9728](https://www.rfc-editor.org/rfc/rfc9728.html) · [RFC 9767](https://www.rfc-editor.org/rfc/rfc9767.html) · [RFC 9864](https://www.rfc-editor.org/rfc/rfc9864.html)
  [RFC 9901](https://www.rfc-editor.org/rfc/rfc9901.html) · [RFC 9964](https://www.rfc-editor.org/rfc/rfc9964.html) · [RFC 10017](https://www.rfc-editor.org/rfc/rfc10017.html) · [RFC 10027](https://www.rfc-editor.org/rfc/rfc10027.html)
- **RFC Editor, catalogue-only RFCs in section 6.2:**
  [RFC 6616](https://www.rfc-editor.org/rfc/rfc6616.html) · [RFC 7628](https://www.rfc-editor.org/rfc/rfc7628.html) · [RFC 7635](https://www.rfc-editor.org/rfc/rfc7635.html) · [RFC 7644](https://www.rfc-editor.org/rfc/rfc7644.html) · [RFC 7846](https://www.rfc-editor.org/rfc/rfc7846.html) · [RFC 7853](https://www.rfc-editor.org/rfc/rfc7853.html) · [RFC 8392](https://www.rfc-editor.org/rfc/rfc8392.html) · [RFC 8417](https://www.rfc-editor.org/rfc/rfc8417.html)
  [RFC 8472](https://www.rfc-editor.org/rfc/rfc8472.html) · [RFC 8473](https://www.rfc-editor.org/rfc/rfc8473.html) · [RFC 8485](https://www.rfc-editor.org/rfc/rfc8485.html) · [RFC 8620](https://www.rfc-editor.org/rfc/rfc8620.html) · [RFC 8747](https://www.rfc-editor.org/rfc/rfc8747.html) · [RFC 8898](https://www.rfc-editor.org/rfc/rfc8898.html) · [RFC 8935](https://www.rfc-editor.org/rfc/rfc8935.html) · [RFC 8936](https://www.rfc-editor.org/rfc/rfc8936.html)
  [RFC 9200](https://www.rfc-editor.org/rfc/rfc9200.html) · [RFC 9201](https://www.rfc-editor.org/rfc/rfc9201.html) · [RFC 9202](https://www.rfc-editor.org/rfc/rfc9202.html) · [RFC 9203](https://www.rfc-editor.org/rfc/rfc9203.html) · [RFC 9237](https://www.rfc-editor.org/rfc/rfc9237.html) · [RFC 9430](https://www.rfc-editor.org/rfc/rfc9430.html) · [RFC 9431](https://www.rfc-editor.org/rfc/rfc9431.html) · [RFC 9493](https://www.rfc-editor.org/rfc/rfc9493.html)
  [RFC 9509](https://www.rfc-editor.org/rfc/rfc9509.html) · [RFC 9560](https://www.rfc-editor.org/rfc/rfc9560.html) · [RFC 9594](https://www.rfc-editor.org/rfc/rfc9594.html) · [RFC 9679](https://www.rfc-editor.org/rfc/rfc9679.html) · [RFC 9725](https://www.rfc-editor.org/rfc/rfc9725.html) · [RFC 9770](https://www.rfc-editor.org/rfc/rfc9770.html) · [RFC 9967](https://www.rfc-editor.org/rfc/rfc9967.html) · [RFC 10006](https://www.rfc-editor.org/rfc/rfc10006.html)
- **RFC Editor, BCP sets:**
  [BCP 212](https://www.rfc-editor.org/info/bcp212) · [BCP 240](https://www.rfc-editor.org/info/bcp240) · [BCP 247](https://www.rfc-editor.org/info/bcp247) ·
  [RFC 9325](https://www.rfc-editor.org/rfc/rfc9325.html) · [RFC 9852](https://www.rfc-editor.org/rfc/rfc9852.html) (BCP 195, step 41)
- **RFC Editor and IETF, terms in section 1:**
  [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119.html) · [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174.html) · [IETF Datatracker](https://datatracker.ietf.org/)
- **Internet-Draft texts (IETF archive):**
  [draft-fett-oauth-dpop-00](https://www.ietf.org/archive/id/draft-fett-oauth-dpop-00.txt) · [draft-hammer-oauth-v2-mac-token-00](https://www.ietf.org/archive/id/draft-hammer-oauth-v2-mac-token-00.txt) · [draft-hardt-oauth-01](https://www.ietf.org/archive/id/draft-hardt-oauth-01.txt) · [draft-ietf-oauth-browser-based-apps-00](https://www.ietf.org/archive/id/draft-ietf-oauth-browser-based-apps-00.txt)
  [draft-ietf-oauth-identity-chaining-17](https://www.ietf.org/archive/id/draft-ietf-oauth-identity-chaining-17.txt) · [draft-ietf-oauth-rfc7523bis-11](https://www.ietf.org/archive/id/draft-ietf-oauth-rfc7523bis-11.txt) · [draft-ietf-oauth-rfc8725bis-10](https://www.ietf.org/archive/id/draft-ietf-oauth-rfc8725bis-10.txt) · [draft-ietf-oauth-security-topics-29](https://www.ietf.org/archive/id/draft-ietf-oauth-security-topics-29.txt)
  [draft-ietf-oauth-signed-http-request-03](https://www.ietf.org/archive/id/draft-ietf-oauth-signed-http-request-03.txt) · [draft-ietf-oauth-spop-00](https://www.ietf.org/archive/id/draft-ietf-oauth-spop-00.txt) · [draft-ietf-oauth-status-list-21](https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-21.txt) · [draft-ietf-oauth-v2-00](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-00.txt)
  [draft-ietf-oauth-v2-06](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-06.txt) · [draft-ietf-oauth-v2-1-00](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-1-00.txt) · [draft-ietf-oauth-v2-1-16](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-1-16.txt) · [draft-ietf-oauth-v2-26](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-26.txt)
  [draft-ietf-oauth-v2-28](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-28.txt) · [draft-ietf-oauth-v2-29](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-29.txt) · [draft-ietf-oauth-v2-bearer-00](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-bearer-00.txt) · [draft-ietf-oauth-v2-http-mac-05](https://www.ietf.org/archive/id/draft-ietf-oauth-v2-http-mac-05.txt)
  [draft-parecki-oauth-v2-1-00](https://www.ietf.org/archive/id/draft-parecki-oauth-v2-1-00.txt) · [draft-sakimura-oauth-tcse-00](https://www.ietf.org/archive/id/draft-sakimura-oauth-tcse-00.txt)
- **Datatracker, historical and dead drafts:**
  [draft-denniss-oauth-device-flow](https://datatracker.ietf.org/doc/draft-denniss-oauth-device-flow/) · [draft-hammer-oauth](https://datatracker.ietf.org/doc/draft-hammer-oauth/) · [draft-hardt-oauth](https://datatracker.ietf.org/doc/draft-hardt-oauth/) · [draft-ietf-oauth-authentication](https://datatracker.ietf.org/doc/draft-ietf-oauth-authentication/)
  [draft-ietf-oauth-browser-based-apps](https://datatracker.ietf.org/doc/draft-ietf-oauth-browser-based-apps/) · [draft-ietf-oauth-closing-redirectors](https://datatracker.ietf.org/doc/draft-ietf-oauth-closing-redirectors/) · [draft-ietf-oauth-cross-device-security](https://datatracker.ietf.org/doc/draft-ietf-oauth-cross-device-security/) · [draft-ietf-oauth-distributed](https://datatracker.ietf.org/doc/draft-ietf-oauth-distributed/)
  [draft-ietf-oauth-dpop](https://datatracker.ietf.org/doc/draft-ietf-oauth-dpop/) · [draft-ietf-oauth-dyn-reg-metadata](https://datatracker.ietf.org/doc/draft-ietf-oauth-dyn-reg-metadata/) · [draft-ietf-oauth-incremental-authz](https://datatracker.ietf.org/doc/draft-ietf-oauth-incremental-authz/) · [draft-ietf-oauth-mix-up-mitigation](https://datatracker.ietf.org/doc/draft-ietf-oauth-mix-up-mitigation/)
  [draft-ietf-oauth-pop-architecture](https://datatracker.ietf.org/doc/draft-ietf-oauth-pop-architecture/) · [draft-ietf-oauth-pop-key-distribution](https://datatracker.ietf.org/doc/draft-ietf-oauth-pop-key-distribution/) · [draft-ietf-oauth-reciprocal](https://datatracker.ietf.org/doc/draft-ietf-oauth-reciprocal/) · [draft-ietf-oauth-security-topics](https://datatracker.ietf.org/doc/draft-ietf-oauth-security-topics/)
  [draft-ietf-oauth-signed-http-request](https://datatracker.ietf.org/doc/draft-ietf-oauth-signed-http-request/) · [draft-ietf-oauth-token-binding](https://datatracker.ietf.org/doc/draft-ietf-oauth-token-binding/) · [draft-ietf-oauth-use-cases](https://datatracker.ietf.org/doc/draft-ietf-oauth-use-cases/) · [draft-ietf-oauth-v2](https://datatracker.ietf.org/doc/draft-ietf-oauth-v2/)
  [draft-ietf-oauth-v2-http-mac](https://datatracker.ietf.org/doc/draft-ietf-oauth-v2-http-mac/) · [draft-ietf-oauth-web-delegation](https://datatracker.ietf.org/doc/draft-ietf-oauth-web-delegation/) · [draft-jones-json-web-token](https://datatracker.ietf.org/doc/draft-jones-json-web-token/) · [draft-jones-oauth-discovery](https://datatracker.ietf.org/doc/draft-jones-oauth-discovery/)
  [draft-jones-oauth-resource-metadata](https://datatracker.ietf.org/doc/draft-jones-oauth-resource-metadata/) · [draft-lodderstedt-oauth-security-topics](https://datatracker.ietf.org/doc/draft-lodderstedt-oauth-security-topics/) · [draft-richer-oauth-introspection](https://datatracker.ietf.org/doc/draft-richer-oauth-introspection/) · [draft-richer-transactional-authz](https://datatracker.ietf.org/doc/draft-richer-transactional-authz/)
  [draft-wdenniss-oauth-native-apps](https://datatracker.ietf.org/doc/draft-wdenniss-oauth-native-apps/)
- **Datatracker, active drafts in section 7:**
  [draft-ietf-jose-deprecate-none-rsa15](https://datatracker.ietf.org/doc/draft-ietf-jose-deprecate-none-rsa15/) · [draft-ietf-jose-hpke-encrypt](https://datatracker.ietf.org/doc/draft-ietf-jose-hpke-encrypt/) · [draft-ietf-oauth-attestation-based-client-auth](https://datatracker.ietf.org/doc/draft-ietf-oauth-attestation-based-client-auth/) · [draft-ietf-oauth-client-id-metadata-document](https://datatracker.ietf.org/doc/draft-ietf-oauth-client-id-metadata-document/)
  [draft-ietf-oauth-deferred-token-response](https://datatracker.ietf.org/doc/draft-ietf-oauth-deferred-token-response/) · [draft-ietf-oauth-first-party-apps](https://datatracker.ietf.org/doc/draft-ietf-oauth-first-party-apps/) · [draft-ietf-oauth-identity-assertion-authz-grant](https://datatracker.ietf.org/doc/draft-ietf-oauth-identity-assertion-authz-grant/) · [draft-ietf-oauth-identity-chaining](https://datatracker.ietf.org/doc/draft-ietf-oauth-identity-chaining/)
  [draft-ietf-oauth-rar-metadata-remediation](https://datatracker.ietf.org/doc/draft-ietf-oauth-rar-metadata-remediation/) · [draft-ietf-oauth-refresh-token-expiration](https://datatracker.ietf.org/doc/draft-ietf-oauth-refresh-token-expiration/) · [draft-ietf-oauth-rfc7523bis](https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc7523bis/) · [draft-ietf-oauth-rfc8725bis](https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc8725bis/)
  [draft-ietf-oauth-sd-jwt-vc](https://datatracker.ietf.org/doc/draft-ietf-oauth-sd-jwt-vc/) · [draft-ietf-oauth-security-topics-update](https://datatracker.ietf.org/doc/draft-ietf-oauth-security-topics-update/) · [draft-ietf-oauth-spiffe-client-auth](https://datatracker.ietf.org/doc/draft-ietf-oauth-spiffe-client-auth/) · [draft-ietf-oauth-status-list](https://datatracker.ietf.org/doc/draft-ietf-oauth-status-list/)
  [draft-ietf-oauth-transaction-tokens](https://datatracker.ietf.org/doc/draft-ietf-oauth-transaction-tokens/) · [draft-ietf-oauth-v2-1](https://datatracker.ietf.org/doc/draft-ietf-oauth-v2-1/)
- **IETF charters, meetings and mailing list:**
  [charter-ietf-oauth-01](https://www.ietf.org/charter/charter-ietf-oauth-01.txt) · [charter-ietf-oauth-03](https://www.ietf.org/charter/charter-ietf-oauth-03.txt) · [charter-ietf-oauth-06](https://www.ietf.org/charter/charter-ietf-oauth-06.txt) · [GNAP WG history](https://datatracker.ietf.org/group/gnap/history/)
  [IETF 73 BoF minutes](https://www.ietf.org/proceedings/73/minutes/oauth.txt) · [IETF 74 BoF minutes](https://www.ietf.org/proceedings/74/minutes/oauth.txt) · [OAuth interim minutes, 2025-01-27](https://datatracker.ietf.org/meeting/interim-2025-oauth-04/materials/minutes-interim-2025-oauth-04-202501271700-00) · [OAuth WG charter history](https://datatracker.ietf.org/doc/charter-ietf-oauth/)
  [OAuth WG milestone events](https://datatracker.ietf.org/api/v1/group/groupevent/?group=1748&format=json&limit=300) · [RFC 5849 publication event](https://datatracker.ietf.org/api/v1/doc/docevent/?doc__name=rfc5849&type=published_rfc&format=json) · [RFC 6819 publication event](https://datatracker.ietf.org/api/v1/doc/docevent/?doc__name=rfc6819&type=published_rfc&format=json) · [WG mix-up advisory, 2016-01-10](https://mailarchive.ietf.org/arch/msg/oauth/JIVxFBGsJBVtm7ljwJhPUm3Fr-w/)
- **oauth.net and archived community pages:**
  ["OAuth 2.0 and the Road to Hell", 2012 (archived)](https://web.archive.org/web/20120728020635/http://hueniverse.com:80/2012/07/oauth-2-0-and-the-road-to-hell/) · [dev.twitter.com, 2010 (archived)](https://web.archive.org/web/20100901044917/http://dev.twitter.com/) · [OAuth Core 1.0](https://oauth.net/core/1.0/) · [OAuth Core 1.0a](https://oauth.net/core/1.0a/)
  [OAuth WRAP group, 2009 (archived)](https://web.archive.org/web/20091123085939/http://groups.google.com:80/group/oauth-wrap-wg) · [oauth.net Introduction](https://oauth.net/about/introduction/) · [oauth.net/1](https://oauth.net/1/) · [oauth.net/2.1](https://oauth.net/2.1/)
  [Security Advisory 2009.1](https://oauth.net/advisories/2009-1/) · [session-fixation explainer, 2009 (archived)](https://web.archive.org/web/20090912004026/http://hueniverse.com:80/2009/04/explaining-the-oauth-session-fixation-attack/)
- **OpenID Foundation:**
  [Back-Channel Logout](https://openid.net/specs/openid-connect-backchannel-1_0.html) · [CIBA Core 1.0](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html) · [Credential Issuance 1.0 final (news)](https://openid.net/openid-for-verifiable-credential-issuance-1-final-specification-approved/) · [FAPI 2.0 Security Profile](https://openid.net/specs/fapi-security-profile-2_0-final.html)
  [Form Post Response Mode](https://openid.net/specs/oauth-v2-form-post-response-mode-1_0.html) · [Front-Channel Logout](https://openid.net/specs/openid-connect-frontchannel-1_0.html) · [JARM (current, errata set 1)](https://openid.net/specs/oauth-v2-jarm.html) · [JARM Draft-02 (2018)](https://openid.net/specs/openid-financial-api-jarm.html)
  [JARM Final (approved text)](https://openid.net/specs/oauth-v2-jarm-final.html) · [Multiple Response Types](https://openid.net/specs/oauth-v2-multiple-response-types-1_0.html) · [OIDC as ISO/IEC standard (news)](https://openid.net/10-years-on-openidconnect-published-as-iso-spec/) · [OIDC Core](https://openid.net/specs/openid-connect-core-1_0.html)
  [OIDC Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html) · [OIDC Registration](https://openid.net/specs/openid-connect-registration-1_0.html) · [OpenID Federation 1.0 final (news)](https://openid.net/openid-federation-1-0-final-specification-approved/) · [private_key_jwt disclosure notice, 2025-01](https://openid.net/wp-content/uploads/2025/01/OIDF-Responsible-Disclosure-Notice-on-Security-Vulnerability-for-private_key_jwt.pdf)
  [RP-Initiated Logout](https://openid.net/specs/openid-connect-rpinitiated-1_0.html) · [Session Management](https://openid.net/specs/openid-connect-session-1_0.html) · [Verifiable Presentations 1.0 final (news)](https://openid.net/openid-for-verifiable-presentations-1-0-final-specification-approved/)
- **Research, security reports and other:**
  [arXiv:1601.01229 (Fett, Küsters, Schmitz)](https://arxiv.org/abs/1601.01229) · [Chrome "Intent to Remove: Token Binding"](https://groups.google.com/a/chromium.org/g/blink-dev/c/OkdLUyYmY1E/m/YJrsadYKDQAJ) · [ePrint 2025/629 (audience injection)](https://eprint.iacr.org/2025/629) · [IDPro on OSW 2025](https://idpro.org/the-oauth-security-workshop-2025/)
  [JWT library vulnerabilities, 2015 (Auth0 blog)](https://auth0.com/blog/critical-vulnerabilities-in-json-web-token-libraries/) · [MCP authorization 2025-03-26](https://modelcontextprotocol.io/specification/2025-03-26/basic/authorization) · [MCP authorization 2025-06-18](https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization) · [MCP authorization 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization)
  [OSW 2016](https://osw2016.sec.uni-stuttgart.de/) · [self-issued.info, February 2014](https://self-issued.info/?m=201402) · [self-issued.info, May 2026 post](https://self-issued.info/?p=2861)
