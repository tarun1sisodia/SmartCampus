enum UIStyle {
  industrialCorporate(
    'INDUSTRIAL CORPORATE',
    'Sharp edges, high contrast, bold borders.',
  ),
  softMinimalist(
    'SOFT MINIMALIST',
    'Rounded, airy, and clean design.',
  ),
  glassmorphism(
    'GLASSMORPHISM',
    'Frosted glass with vibrant gradients.',
  ),
  neumorphism(
    'NEUMORPHISM',
    'Tactile, soft, extruded surfaces.',
  ),
  material3(
    'MATERIAL 3',
    'Google\'s latest dynamic design.',
  ),
  cupertinoPro(
    'CUPERTINO PRO',
    'Polished and reflective iOS style.',
  ),
  cyberpunkNeon(
    'CYBERPUNK NEON',
    'Dark theme with glowing neon accents.',
  ),
  brutalistBold(
    'BRUTALIST BOLD',
    'Raw, high-contrast, oversized elements.',
  ),
  academicClassic(
    'ACADEMIC CLASSIC',
    'Traditional, serif-based formal grid.',
  ),
  fluentLayered(
    'FLUENT LAYERED',
    'Acrylic depth and reveal highlights.',
  );

  final String label;
  final String description;

  const UIStyle(this.label, this.description);
}
