/// TSizes implements:
/// - Fitts's Law: Appropriate sizing for interactive elements
/// - Law of Proximity: Consistent spacing system
/// - Miller's Law: Limited number of size options
/// - Law of Similarity: Consistent sizing patterns
class TSizes {
  TSizes._();

  // SPACING SYSTEM - For consistent spacing throughout the app (Law of Proximity)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ICON SIZES - For consistent icon sizing (Law of Similarity)
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // FONT SIZES - For consistent typography (Visual Hierarchy)
  static const double fontSizeSm = 14.0;
  static const double fontSizeMd = 16.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeXl = 20.0;
  static const double fontSizeXxl = 24.0;

  // BUTTON SIZES - For appropriate touch targets (Fitts's Law)
  static const double buttonHeight = 48.0; // Minimum recommended touch target
  static const double buttonRadius = 10.0;
  static const double buttonWidth = 120.0;
  static const double buttonElevation = 2.0;
  
  // APPBAR HEIGHT - For consistent navigation (Jakob's Law)
  static const double appBarHeight = 56.0;

  // IMAGE SIZES - For consistent imagery
  static const double imageThumbSize = 80.0;
  static const double imagePreviewSize = 150.0;
  static const double imageBannerHeight = 200.0;

  // SPACING BETWEEN ELEMENTS - For consistent layout (Law of Proximity)
  static const double defaultSpace = 16.0;
  static const double spaceBtwItems = 16.0;
  static const double spaceBtwSections = 32.0;
  static const double spaceBtwInputFields = 16.0;

  // BORDER RADIUS - For consistent component styling (Law of Similarity)
  static const double borderRadiusXs = 4.0;
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;
  static const double borderRadiusLg = 16.0;
  static const double borderRadiusXl = 20.0;

  // DIVIDER HEIGHT - For subtle separation
  static const double dividerHeight = 1.0;
  static const double dividerThickness = 1.0;

  // PRODUCT ITEM DIMENSIONS - For consistent product display
  static const double productImageSize = 120.0;
  static const double productImageRadius = 16.0;
  static const double productItemHeight = 160.0;

  // INPUT FIELD - For consistent form elements (Fitts's Law)
  static const double inputFieldRadius = 12.0;
  static const double inputFieldHeight = 56.0;
  static const double inputIconSize = 24.0;

  // CARD SIZES - For consistent card styling (Law of Common Region)
  static const double cardRadiusLg = 16.0;
  static const double cardRadiusMd = 12.0;
  static const double cardRadiusSm = 8.0;
  static const double cardRadiusXs = 6.0;
  static const double cardElevation = 2.0;
  static const double cardBorderWidth = 1.0;

  // CHIP RADIUS - For consistent chip styling
  static const double chipRadius = 8.0;

  // IMAGE CAROUSEL HEIGHT - For consistent carousel display
  static const double imageCarouselHeight = 200.0;

  // LOADING INDICATOR SIZE - For consistent loading states
  static const double loadingIndicatorSize = 36.0;
  static const double loadingIndicatorSmall = 24.0;

  // GRID VIEW SPACING - For consistent grid layouts
  static const double gridViewSpacing = 16.0;
  static const double gridViewChildAspectRatio = 0.7;
  
  // BOTTOM NAVIGATION BAR - For consistent navigation (Jakob's Law)
  static const double bottomNavBarHeight = 80.0;
  static const double bottomNavBarIconSize = 24.0;
  
  // AVATAR SIZES - For consistent user representation
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 40.0;
  static const double avatarSizeLarge = 56.0;
  
  // TOOLTIP - For consistent help elements
  static const double tooltipRadius = 4.0;
  static const double tooltipHeight = 32.0;
}
