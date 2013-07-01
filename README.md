demo-project
============
<p>This is a demo iOS project compatible with iOS >= 4.3.</p>

<h2>Project Structure</h2>
-----------------
<ul>
<li>Models</li>
<li>Views</li>
<li>Controllers</li>
in addition to: Cells, Helpers and Slices
<ul>

<h2>Helpers</h2>
<ul>
<li>Dlog: simple debugging function that displays a custom message along with filename and line</li>
<li>Localizable: all strings to be localized</li>
<li>Constants: One header file that references all other files</li>
<li>ASIHttpRequest: http://allseeing-i.com/ASIHTTPRequest</li>
<li>SBJson: https://github.com/stig/json-framework/</li>
<li>Google Analytics: https://developers.google.com/analytics/devguides/collection/ios/v2/</li>
<li>MBProgressHUD: https://github.com/jdg/MBProgressHUD</li>
<li>NSString Addons: HTML (remove html tags), URLEncoding, Hex</li>
<li>ODRefreshControl: https://github.com/Sephiroth87/ODRefreshControl‎</li>
<li>SDWebImage: https://github.com/rs/SDWebImage</li>
<li>SMXMLDocument: https://github.com/nfarina/xmldocument‎</li>
<li>UIImage Addons: Alpha, RoundedCorner, Resize</li>
<hl>
<li>RKRequestData: A custom request object that handles building urls and passing parameters either as GET or POST and PUT, and handles response parsing either as JSON or XML</li>
<li>RKTextField: a custom textfield when using a custom background image, and handles insets</li>
<li>CustomButton: reusable button view to reduce repetition of lines of code that set font, alignment and size</li>
<li>RKPageControl: a custom page control for custom bullets</li>
<li>PortraitViewController: a parent controller for all view controllers in a Portrait Application where also some controlleres could be Landscape such as MPMoviePlayer</li>
<li>Networking: a custom networking singleton handler that handles all requests and their responses parsing and passing data among controllers. Starts requests, cancels them, creates timeouts.</li>
</ul>

<h2> Controllers </h2>
<p>The project contains a MainViewController, which extends PortraitViewController. A controller contains a HeaderView, a CenterView and possibly a LeftView.</p>
<p>The Controller implements Delegate methods for basically the HeaderView, the Networking, the Request and others possibly</p>
<p>The controller contains an array that holds request ids, which are handled in the networking and request delegate methods</p>
