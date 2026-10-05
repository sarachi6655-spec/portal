import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable ServiceCard widget
/// Displays:
/// 1. Top image with rounded corners
/// 2. Service title underneath the image
/// 3. Description block below the title
/// 4. Pill-shaped "Read More" button at the bottom
class ServiceCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onReadMorePressed;

  // Optional styling & metadata enhancements
  final String? category;
  final String? startingPrice;
  final double? height;
  final String buttonText;
  final String remarks;

  const ServiceCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onReadMorePressed,
    required this.remarks,
    this.category,
    this.startingPrice,
    this.height,
    this.buttonText = 'Test List',
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const cardRadius = 16.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? (Matrix4.identity()..translate(0, -6, 0)) : Matrix4.identity(),
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
            color: _isHovered ? const Color(0xFF2490EB).withOpacity(0.5) : const Color(0xFFE2E8F0),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? const Color(0xFF2490EB).withOpacity(0.14) : const Color(0x0A000000),
              blurRadius: _isHovered ? 24 : 12,
              offset: Offset(0, _isHovered ? 10 : 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Image with rounded corners
            _buildTopImage(cardRadius),

            // 2. Card Content (Title, Description, and Action Button)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Name and Price in the same row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF18100F),
                            height: 1.25,
                          ),
                        ),
                      ),
                      // if (widget.startingPrice != null) ...[
                      //   const SizedBox(width: 10),
                      //   Padding(
                      //     padding: const EdgeInsets.only(top: 1),
                      //     child: Text(
                      //       widget.startingPrice!.replaceFirst(RegExp(r'^from\s*', caseSensitive: false), ''),
                      //       style: GoogleFonts.montserrat(
                      //         fontSize: 15,
                      //         fontWeight: FontWeight.w700,
                      //         color: const Color(0xFF0F766E),
                      //       ),
                      //     ),
                      //   ),
                      // ],
                    ],
                  ),

                  // Description block below title without empty gap (only when non-empty)
                  if (widget.remarks.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.remarks,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Pill-shaped button at bottom
                  _buildPillReadMoreButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top image with rounded top corners and graceful network/asset/fallback handling
  Widget _buildTopImage(double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      child: Stack(
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: widget.imagePath.trim().isEmpty
                ? _buildFallbackBanner()
                : widget.imagePath.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: widget.imagePath,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2490EB),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => _buildFallbackBanner(),
                      )
                    : Image.asset(
                        widget.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildFallbackBanner(),
                      ),
          ),

          // Subtle gradient overlay for depth
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.04),
                    Colors.black.withOpacity(0.18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fallback graphic when an image URL/asset cannot be loaded
  Widget _buildFallbackBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.biotech_rounded,
          size: 48,
          color: Colors.white.withOpacity(0.35),
        ),
      ),
    );
  }

  /// Styled Pill-shaped "Read More" button
  Widget _buildPillReadMoreButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onReadMorePressed,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF1C7ACB) : const Color(0xFF2490EB),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2490EB).withOpacity(_isHovered ? 0.35 : 0.2),
                blurRadius: _isHovered ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.buttonText,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: _isHovered ? (Matrix4.identity()..translate(3, 0, 0)) : Matrix4.identity(),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
