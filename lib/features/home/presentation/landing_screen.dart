import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/revol_logo.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../data/models/client_portal_details_model.dart';
import '../data/models/service_detail_model.dart';
import 'controllers/home_controller.dart';
import 'widgets/service_card.dart';
import 'widgets/service_details_dialog.dart';
import 'views/our_services_view.dart';

enum LandingPageTab {
  home,
  services,
}

class LandingScreen extends StatefulWidget {
  final VoidCallback onNavigateToLogin;
  final AuthController? authController;
  final VoidCallback? onLoginSuccess;

  const LandingScreen({
    super.key,
    required this.onNavigateToLogin,
    this.authController,
    this.onLoginSuccess,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final HomeController _homeController = HomeController();
  final PageController _sliderController = PageController();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _navUsernameController = TextEditingController();
  final TextEditingController _navPasswordController = TextEditingController();
  final TextEditingController _newsletterEmailController = TextEditingController();

  int _currentSlide = 0;
  Timer? _autoSlideTimer;
  bool _isLoginDropdownOpen = false;
  bool _isLoggingInFromNav = false;
  bool _showScrollTop = false;
  bool _obscureNavPassword = true;
  LandingPageTab _currentTab = LandingPageTab.home;

  @override
  void initState() {
    super.initState();
    _homeController.addListener(_onStateChanged);
    _homeController.loadPortalDetails();
    _homeController.loadClientServices();

    _scrollController.addListener(() {
      final show = _scrollController.hasClients && _scrollController.offset > 280;
      if (show != _showScrollTop) {
        setState(() => _showScrollTop = show);
      }
    });

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      final count = _getValidSlides(_homeController.portalDetails).length;
      if (_sliderController.hasClients && count > 1) {
        final nextPage = (_currentSlide + 1) % count;
        _sliderController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _sliderController.dispose();
    _scrollController.dispose();
    _navUsernameController.dispose();
    _navPasswordController.dispose();
    _newsletterEmailController.dispose();
    _homeController.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  List<ServiceItemDetail> _getAllServices(ClientPortalDetailsModel? details) {
    const angioplastyImg = ServiceItemDetail.angioplastyImageUrl;
    const cardiologyImg = ServiceItemDetail.cardiologyImageUrl;
    const dentalImg = ServiceItemDetail.dentalImageUrl;

    String resolveRealImage(String title, int index) {
      final t = title.toLowerCase();
      if (t.contains('angioplasty')) return angioplastyImg;
      if (t.contains('cardio') || t.contains('heart')) return cardiologyImg;
      if (t.contains('dental') || t.contains('dentist') || t.contains('teeth')) return dentalImg;
      const fallbackPool = [cardiologyImg, angioplastyImg, dentalImg];
      return fallbackPool[index % fallbackPool.length];
    }

    final sample = ServiceItemDetail.sampleServices;
    final rawServices = details?.services ?? [];
    final validServices = rawServices.where((s) => s.title.trim().isNotEmpty || s.content.trim().isNotEmpty).toList();

    if (validServices.isEmpty) {
      return sample;
    }

    return List.generate(validServices.length, (index) {
      final s = validServices[index];
      final sampleMatch = index < sample.length ? sample[index] : sample[index % sample.length];

      final title = s.title.trim().isNotEmpty ? s.title : sampleMatch.title;
      final desc = s.content.trim().isNotEmpty ? _cleanHtml(s.content) : sampleMatch.description;
      final img = resolveRealImage(title, index);

      return ServiceItemDetail(
        id: 'srv_$index',
        title: title,
        description: desc,
        imagePath: img,
        category: sampleMatch.category,
        startingPrice: sampleMatch.startingPrice,
        subServices: sampleMatch.subServices,
      );
    });
  }

  String _cleanHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&').replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  List<String> _extractListItems(String html) {
    if (html.isEmpty) return [];
    final matches = RegExp(r'<li[^>]*>(.*?)</li>', dotAll: true).allMatches(html);
    if (matches.isEmpty) return [];
    return matches.map((m) => _cleanHtml(m.group(1) ?? '')).where((s) => s.isNotEmpty).toList();
  }

  List<String> _extractParagraphs(String html) {
    if (html.isEmpty) return [];
    final clean = html.replaceAll(RegExp(r'<ul[^>]*>.*?</ul>', dotAll: true), '');
    final matches = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true).allMatches(clean);
    final results = matches.map((m) => _cleanHtml(m.group(1) ?? '')).where((s) => s.isNotEmpty).toList();
    if (results.isEmpty) {
      final stripped = _cleanHtml(clean);
      if (stripped.isNotEmpty) results.add(stripped);
    }
    return results;
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _handleNavLogin() async {
    if (widget.authController == null) {
      widget.onNavigateToLogin();
      return;
    }

    final user = _navUsernameController.text.trim();
    final pass = _navPasswordController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your username and password'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoggingInFromNav = true);

    final success = await widget.authController!.login(
      userName: user,
      password: pass,
    );

    if (mounted) {
      setState(() => _isLoggingInFromNav = false);
      if (success) {
        setState(() => _isLoginDropdownOpen = false);
        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.authController!.errorMessage ?? 'Invalid login credentials'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _handleNewsletterSubmit() {
    if (_newsletterEmailController.text.trim().isNotEmpty) {
      _newsletterEmailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for subscribing to Revol LIMS newsletter!'),
          backgroundColor: Color(0xFF007AD5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final details = _homeController.portalDetails;
    final allServices = _getAllServices(details);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Top Contact Bar (Dark Navy #152B5B)
              _buildTopContactBar(isMobile, details),

              // 2. Responsive Sticky Navbar with Brand Logo, Navigation Tabs, Contact and LOGIN buttons
              _buildNavBar(isMobile, isTablet, details),

              // Mobile Sub-Navbar Tab Switcher
              if (isMobile) _buildMobileTabStrip(),

              // 3. Main Scrollable Content
              Expanded(
                child: _homeController.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF007AD5)),
                      )
                    : _currentTab == LandingPageTab.home
                        ? SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              children: [
                                // Hero Carousel Section
                                _buildHeroSlider(context, isMobile, isTablet, details),

                                // Block 1: 4 High-Impact ROI & Metric Cards
                                _buildBlockOneFancyBoxes(context, isMobile, isTablet, details),

                                // Block 2 & 3: Comprehensive Solutions & Medicine Service
                                _buildSolutionShowcase(context, isMobile, isTablet, details),

                                // Block 4: OUR SERVICES (8 Service Cards)
                                _buildBlockFourServicesSection(context, isMobile, isTablet, details),

                                // Block 5: Process Step & Video Showcase
                                _buildBlockFiveVideoSection(context, isMobile, details),

                                // Client Partners Carousel
                                _buildClientsSection(context, isMobile, details),

                                // Executive Multi-Column Footer
                                _buildFooterSection(context, isMobile, isTablet, details),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              children: [
                                // Dedicated Our Services Catalog Page
                                OurServicesView(
                                  services: _homeController.clientServices.isNotEmpty ? _homeController.clientServices : (_homeController.isClientServicesLoading ? [] : allServices),
                                  isLoading: _homeController.isClientServicesLoading,
                                  onBackToHome: () {
                                    setState(() => _currentTab = LandingPageTab.home);
                                    _scrollToTop();
                                  },
                                  isSpace: _homeController.portalDetails ?? ClientPortalDetailsModel(boxOneHeaderOne: '', boxOneHeaderTwo: '', boxoneContent: '', boxoneLink: '', sliderImage1: '', boxTwoHeaderOne: '', boxTwoHeaderTwo: '', boxTwoContent: '', boxTwoLink: '', sliderImage2: '', boxThreeHeaderOne: '', boxThreeHeaderTwo: '', boxThreeContent: '', boxThreeLink: '', sliderImage3: '', headerLogo: '', footerLogo: '', blockOneBoxOneTitle: '', blockOneBoxOneContent: '', blockOneBoxOneIcon: '', blockOneBoxOneLink: '', blockOneBoxTwoTitle: '', blockOneBoxTwoContent: '', blockOneBoxTwoIcon: '', blockOneBoxTwoLink: '', blockOneBoxThreeTitle: '', blockOneBoxThreeContent: '', blockOneBoxThreeIcon: '', blockOneBoxThreeLink: '', blockOneBoxFourTitle: '', blockOneBoxFourContent: '', blockOneBoxFourIcon: '', blockOneBoxFourLink: '', blockTwoHeader: '', blockTwoContent: '', blockTwoImage: '', blockTwoLink: '', blockThreeHeader: '', blockThreeContent: '', blockThreeImage: '', blockThreeLink: '', blockFourHeaderOne: '', blockFourHeaderTwo: '', services: [], blockFiveTitle: '', blockFiveContent: '', blockFiveVideoLink: '', blockFiveHeader: '', clients: [], mobile: '', email: '', address: '', facebook: '', instagram: '', linkedIn: '', youTube: '', gPlus: '', pinterest: '', isServiceWithPrice: false),
                                ),

                                // Executive Multi-Column Footer
                                _buildFooterSection(context, isMobile, isTablet, details),
                              ],
                            ),
                          ),
              ),
            ],
          ),

          // Fly-out Login Dropdown below Navbar
          if (_isLoginDropdownOpen)
            Positioned(
              top: isMobile ? 76 : (38 + 76),
              right: isMobile ? 12 : 48,
              child: _buildLoginDropdown(isMobile),
            ),

          // Floating Scroll to Top Button
          if (_showScrollTop)
            Positioned(
              bottom: 24,
              right: 24,
              child: InkWell(
                onTap: _scrollToTop,
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2490EB),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2490EB).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 1. Top Contact Bar (Dynamically API-Driven & Matching HTML style.css)
  Widget _buildTopContactBar(bool isMobile, ClientPortalDetailsModel? details) {
    if (isMobile) return const SizedBox();

    final mobile = (details?.mobile ?? '').trim();
    final email = (details?.email ?? '').trim();
    final facebook = (details?.facebook ?? '').trim();
    final linkedIn = (details?.linkedIn ?? '').trim();
    final instagram = (details?.instagram ?? '').trim();
    final youTube = (details?.youTube ?? '').trim();

    final hasContact = mobile.isNotEmpty || email.isNotEmpty;
    final hasSocial = facebook.isNotEmpty || linkedIn.isNotEmpty || instagram.isNotEmpty || youTube.isNotEmpty;

    if (!hasContact && !hasSocial) return const SizedBox();

    return Container(
      height: 38,
      color: const Color(0xFF14457B),
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: [
          // Phone
          if (mobile.isNotEmpty) ...[
            InkWell(
              onTap: () => _launchUrl('tel:$mobile'),
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk, color: Colors.white, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    mobile,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (email.isNotEmpty) const SizedBox(width: 24),
          ],

          // Email
          if (email.isNotEmpty) ...[
            InkWell(
              onTap: () => _launchUrl('mailto:$email'),
              child: Row(
                children: [
                  const Icon(Icons.mail_outline, color: Colors.white, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    email,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Social icons with vertical dividers
          if (facebook.isNotEmpty) _buildTopSocialIcon(Icons.facebook, facebook),
          if (facebook.isNotEmpty && linkedIn.isNotEmpty) _buildTopDivider(),
          if (linkedIn.isNotEmpty) _buildTopSocialIcon(Icons.business, linkedIn),
          if (linkedIn.isNotEmpty && instagram.isNotEmpty) _buildTopDivider(),
          if (instagram.isNotEmpty) _buildTopSocialIcon(Icons.camera_alt, instagram),
          if (instagram.isNotEmpty && youTube.isNotEmpty) _buildTopDivider(),
          if (youTube.isNotEmpty) _buildTopSocialIcon(Icons.smart_display, youTube),
        ],
      ),
    );
  }

  Widget _buildTopDivider() {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildTopSocialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }

  // 2. Responsive Navbar
  Widget _buildNavBar(bool isMobile, bool isTablet, ClientPortalDetailsModel? details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isUltraNarrow = screenWidth < 360;

    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? (isUltraNarrow ? 8 : 12) : 48),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0x15000000))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo scaled down flexibly on narrow screens
          Flexible(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: (details?.headerLogo ?? '').trim().isNotEmpty && details!.headerLogo.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: details.headerLogo,
                      height: isMobile ? 38 : 46,
                      fit: BoxFit.contain,
                      errorWidget: (c, u, e) => RevolLogo(fontSize: isUltraNarrow ? 17 : (isMobile ? 20 : 26)),
                    )
                  : RevolLogo(fontSize: isUltraNarrow ? 17 : (isMobile ? 20 : 26)),
            ),
          ),

          SizedBox(width: isUltraNarrow ? 4 : 8),

          // Desktop / Tablet Navigation Tabs (Home & Our Services)
          if (!isMobile) ...[
            const SizedBox(width: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNavTabItem('Home', LandingPageTab.home, Icons.home_rounded),
                const SizedBox(width: 8),
                _buildNavTabItem('Services', LandingPageTab.services, Icons.science_rounded),
              ],
            ),
            const Spacer(),
          ],

          // Contact >> Button
          Row(
            children: [
              InkWell(
                onTap: () {
                  final email = (details?.email ?? '').trim();
                  final mobile = (details?.mobile ?? '').trim();
                  final contactMsg = email.isNotEmpty && mobile.isNotEmpty ? 'Contact: $email | $mobile' : (email.isNotEmpty ? 'Email: $email' : (mobile.isNotEmpty ? 'Phone: $mobile' : ''));
                  if (contactMsg.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(contactMsg),
                        backgroundColor: const Color(0xFF2490EB),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isUltraNarrow ? 6 : (isMobile ? 9 : 16),
                    vertical: isMobile ? 7 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2490EB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Contact',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: isUltraNarrow ? 11 : (isMobile ? 12 : 13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.double_arrow_rounded,
                        color: Colors.white,
                        size: isUltraNarrow ? 11 : (isMobile ? 12 : 14),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: isUltraNarrow ? 4 : 8),

              // LOGIN Button (Toggles Fly-out Login Dropdown)
              InkWell(
                onTap: () => setState(() => _isLoginDropdownOpen = !_isLoginDropdownOpen),
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isUltraNarrow ? 6 : (isMobile ? 9 : 16),
                    vertical: isMobile ? 7 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2490EB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LOGIN',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: isUltraNarrow ? 11 : (isMobile ? 12 : 13),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.power_settings_new_rounded,
                        color: Colors.white,
                        size: isUltraNarrow ? 11 : (isMobile ? 12 : 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavTabItem(String label, LandingPageTab tab, IconData icon) {
    final isSelected = _currentTab == tab;
    return InkWell(
      onTap: () {
        if (_currentTab != tab) {
          setState(() => _currentTab = tab);
          _scrollToTop();
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2490EB).withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF2490EB).withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF2490EB) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? const Color(0xFF2490EB) : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTabStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMobileTabButton('Home', Icons.home_rounded, LandingPageTab.home),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMobileTabButton('Services', Icons.science_rounded, LandingPageTab.services),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTabButton(String label, IconData icon, LandingPageTab tab) {
    final isSelected = _currentTab == tab;
    return InkWell(
      onTap: () {
        if (_currentTab != tab) {
          setState(() => _currentTab = tab);
          _scrollToTop();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2490EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Interactive Fly-out Login Dropdown
  Widget _buildLoginDropdown(bool isMobile) {
    return Container(
      width: isMobile ? 300 : 340,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Username Label
          Text(
            'Username or Email:',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),

          // Username Field
          TextField(
            controller: _navUsernameController,
            style: GoogleFonts.montserrat(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Username or Email',
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Password Label
          Text(
            'Password:',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),

          // Password Field
          TextField(
            controller: _navPasswordController,
            obscureText: _obscureNavPassword,
            style: GoogleFonts.montserrat(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Password',
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNavPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: const Color(0xFF64748B),
                ),
                onPressed: () {
                  setState(() => _obscureNavPassword = !_obscureNavPassword);
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // LOGIN Button (Dark Navy #14457B)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoggingInFromNav ? null : _handleNavLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14457B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              child: _isLoggingInFromNav
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'LOGIN',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
            ),
          ),

          // const SizedBox(height: 12),

          // Switch to Fullscreen Login Link
          // Center(
          //   child: InkWell(
          //     onTap: () {
          //       setState(() => _isLoginDropdownOpen = false);
          //       widget.onNavigateToLogin();
          //     },
          //     child: Text(
          //       'Open Full Screen Portal Sign In →',
          //       style: GoogleFonts.montserrat(
          //         fontSize: 11,
          //         fontWeight: FontWeight.w600,
          //         color: const Color(0xFF007AD5),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getValidSlides(ClientPortalDetailsModel? details) {
    final rawSlides = [
      {
        'tag': (details?.boxOneHeaderOne ?? '').trim(),
        'title': (details?.boxOneHeaderTwo ?? '').trim(),
        'content': (details?.boxoneContent ?? '').trim(),
        'image': (details?.sliderImage1 ?? '').trim(),
        'link': (details?.boxoneLink ?? '').trim(),
      },
      {
        'tag': (details?.boxTwoHeaderOne ?? '').trim(),
        'title': (details?.boxTwoHeaderTwo ?? '').trim(),
        'content': (details?.boxTwoContent ?? '').trim(),
        'image': (details?.sliderImage2 ?? '').trim(),
        'link': (details?.boxTwoLink ?? '').trim(),
      },
      {
        'tag': (details?.boxThreeHeaderOne ?? '').trim(),
        'title': (details?.boxThreeHeaderTwo ?? '').trim(),
        'content': (details?.boxThreeContent ?? '').trim(),
        'image': (details?.sliderImage3 ?? '').trim(),
        'link': (details?.boxThreeLink ?? '').trim(),
      },
    ];

    return rawSlides.where((slide) {
      final tag = (slide['tag'] ?? '').trim();
      final title = (slide['title'] ?? '').trim();
      final content = (slide['content'] ?? '').trim();
      final image = (slide['image'] ?? '').trim();
      final link = (slide['link'] ?? '').trim();
      return tag.isNotEmpty || title.isNotEmpty || content.isNotEmpty || image.isNotEmpty || link.isNotEmpty;
    }).toList();
  }

  void _prevSlide(int totalSlides) {
    if (_sliderController.hasClients && totalSlides > 1) {
      final prevPage = (_currentSlide - 1 + totalSlides) % totalSlides;
      _sliderController.animateToPage(
        prevPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _nextSlide(int totalSlides) {
    if (_sliderController.hasClients && totalSlides > 1) {
      final nextPage = (_currentSlide + 1) % totalSlides;
      _sliderController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  // Hero Section
  Widget _buildHeroSlider(BuildContext context, bool isMobile, bool isTablet, ClientPortalDetailsModel? details) {
    final slides = _getValidSlides(details);

    if (slides.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    // Mobile banner is concise and compact (380px), desktop adapts to full screen
    final sliderHeight = isMobile ? 380.0 : (isTablet ? 480.0 : (screenHeight - 114.0).clamp(560.0, 780.0));

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Slide PageView
          SizedBox(
            height: sliderHeight,
            child: PageView.builder(
              controller: _sliderController,
              onPageChanged: (idx) => setState(() => _currentSlide = idx),
              itemCount: slides.length,
              itemBuilder: (context, index) {
                final slide = slides[index];
                return _buildSingleSlide(slide, isMobile, isTablet, sliderHeight);
              },
            ),
          ),

          // Desktop & Tablet Navigation Arrows (only when multiple slides exist)
          if (!isMobile && slides.length > 1) ...[
            Positioned(
              left: 20,
              top: 0,
              bottom: 40,
              child: Center(
                child: _buildSliderNavButton(
                  icon: Icons.chevron_left,
                  onTap: () => _prevSlide(slides.length),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 0,
              bottom: 40,
              child: Center(
                child: _buildSliderNavButton(
                  icon: Icons.chevron_right,
                  onTap: () => _nextSlide(slides.length),
                ),
              ),
            ),
          ],

          // Slide indicator dots (only when multiple slides exist)
          if (slides.length > 1)
            Positioned(
              bottom: isMobile ? 8 : 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (idx) {
                  final isActive = _currentSlide == idx;
                  return InkWell(
                    onTap: () {
                      if (_sliderController.hasClients) {
                        _sliderController.animateToPage(
                          idx,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? (isMobile ? 18 : 26) : 6,
                      height: isMobile ? 5 : 7,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF2490EB) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSliderNavButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withOpacity(0.85),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          child: Icon(icon, color: const Color(0xFF14457B), size: 26),
        ),
      ),
    );
  }

  Widget _buildSingleSlide(Map<String, String> slide, bool isMobile, bool isTablet, double height) {
    final imageUrl = (slide['image'] ?? '').trim();
    final hasImage = imageUrl.isNotEmpty && imageUrl.startsWith('http');

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Full-Width and Full-Height Background Slide Image (covers entire screen)
        if (hasImage)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              alignment: isMobile ? Alignment.centerRight : Alignment.center,
              width: double.infinity,
              height: double.infinity,
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          ),

        // 2. Subtle soft contrast overlay (without washing out image)
        if (hasImage)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withOpacity(isMobile ? 0.65 : 0.35),
                    Colors.white.withOpacity(0.0),
                  ],
                  stops: [0.0, isMobile ? 0.85 : 0.55],
                ),
              ),
            ),
          ),

        // 3. Left-aligned Text Content Container Layer with responsive layout
        Positioned.fill(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1280),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 36 : 64),
                vertical: isMobile ? 12 : 28,
              ),
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : (isTablet ? 500 : 580),
                ),
                child: SizedBox(
                  height: isMobile ? null : (isTablet ? 340 : 380),
                  child: _buildSlideContent(slide, isMobile, isTablet),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlideContent(Map<String, String> slide, bool isMobile, bool isTablet) {
    final tag = slide['tag'] ?? '';
    final title = slide['title'] ?? '';
    final content = _cleanHtml(slide['content'] ?? '');
    final link = (slide['link'] ?? '').trim();
    final hasLink = link.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        // Tag Header with exact #D3E9FB pill badge
        if (tag.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2 : 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD3E9FB),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              tag.toUpperCase(),
              style: GoogleFonts.montserrat(
                color: const Color(0xFF14457B),
                fontSize: isMobile ? 11 : 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 6 : 14),
        ],

        // Headline
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: isMobile ? 20 : (isTablet ? 34 : 46),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF18100F),
              height: 1.15,
              letterSpacing: -0.4,
            ),
            maxLines: isMobile ? 3 : 4,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isMobile ? 6 : 14),
        ],

        // Subtitle
        if (content.isNotEmpty) ...[
          Text(
            content,
            style: GoogleFonts.montserrat(
              fontSize: isMobile ? 12 : 15,
              color: const Color(0xFF18100F),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
            maxLines: isMobile ? 3 : 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // READ MORE + Button only if link is present and not empty
        if (hasLink) ...[
          if (!isMobile) const Spacer(),
          SizedBox(height: isMobile ? 10 : 18),
          InkWell(
            onTap: () => _launchUrl(link),
            borderRadius: BorderRadius.circular(3),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2490EB),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2490EB).withOpacity(0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'READ MORE',
                    style: GoogleFonts.montserrat(
                      fontSize: isMobile ? 11 : 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.add, size: isMobile ? 14 : 16, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Block 1: 4 Cards (Dynamically API-Driven & Collapsible)
  Widget _buildBlockOneFancyBoxes(BuildContext context, bool isMobile, bool isTablet, ClientPortalDetailsModel? details) {
    final rawBoxes = [
      {
        'title': (details?.blockOneBoxOneTitle ?? '').trim(),
        'content': (details?.blockOneBoxOneContent ?? '').trim(),
        'icon': (details?.blockOneBoxOneIcon ?? '').trim(),
        'link': (details?.blockOneBoxOneLink ?? '').trim(),
        'avatarType': 'orange_person',
      },
      {
        'title': (details?.blockOneBoxTwoTitle ?? '').trim(),
        'content': (details?.blockOneBoxTwoContent ?? '').trim(),
        'icon': (details?.blockOneBoxTwoIcon ?? '').trim(),
        'link': (details?.blockOneBoxTwoLink ?? '').trim(),
        'avatarType': 'black_female',
      },
      {
        'title': (details?.blockOneBoxThreeTitle ?? '').trim(),
        'content': (details?.blockOneBoxThreeContent ?? '').trim(),
        'icon': (details?.blockOneBoxThreeIcon ?? '').trim(),
        'link': (details?.blockOneBoxThreeLink ?? '').trim(),
        'avatarType': 'photo_scientist',
      },
      {
        'title': (details?.blockOneBoxFourTitle ?? '').trim(),
        'content': (details?.blockOneBoxFourContent ?? '').trim(),
        'icon': (details?.blockOneBoxFourIcon ?? '').trim(),
        'link': (details?.blockOneBoxFourLink ?? '').trim(),
        'avatarType': 'photo_lab',
      },
    ];

    // Filter out completely empty boxes
    final boxes = rawBoxes.where((box) {
      final title = box['title'] ?? '';
      final content = box['content'] ?? '';
      final icon = box['icon'] ?? '';
      final link = box['link'] ?? '';
      return title.isNotEmpty || content.isNotEmpty || icon.isNotEmpty || link.isNotEmpty;
    }).toList();

    // If all cards are empty or null, hide the entire block cleanly
    if (boxes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 32 : 48),
        vertical: 24,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: isMobile
              ? Column(
                  children: boxes
                      .map((box) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildFancyBoxCard(box, isMobile: true),
                          ))
                      .toList(),
                )
              : isTablet
                  ? Column(
                      children: [
                        for (int r = 0; r < (boxes.length / 2).ceil(); r++) ...[
                          if (r > 0) const SizedBox(height: 20),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: _buildFancyBoxCard(boxes[r * 2])),
                                const SizedBox(width: 20),
                                if (r * 2 + 1 < boxes.length) Expanded(child: _buildFancyBoxCard(boxes[r * 2 + 1])) else const Expanded(child: SizedBox()),
                              ],
                            ),
                          ),
                        ],
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < boxes.length; i++) ...[
                            if (i > 0) const SizedBox(width: 20),
                            Expanded(
                              child: _buildFancyBoxCard(boxes[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildFancyBoxCard(Map<String, String> box, {bool isMobile = false}) {
    final title = box['title'] ?? '';
    final content = _cleanHtml(box['content'] ?? '');
    final link = box['link'] ?? '';
    final icon = box['icon'] ?? '';
    final avatarType = box['avatarType'] ?? 'orange_person';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14001409),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Header Row with Avatar & Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBoxAvatar(icon, avatarType),
              if (title.isNotEmpty) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF18100F),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Paragraph text (only when non-empty)
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),
          if (!isMobile) const Spacer(), // Pins Read More to bottom across all desktop cards equally

          // Read More (only when link is non-empty)
          if (link.isNotEmpty) ...[
            InkWell(
              onTap: () => _launchUrl(link),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Read More',
                    style: GoogleFonts.montserrat(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2490EB),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.add, size: 14, color: Color(0xFF2490EB)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBoxAvatar(String iconUrl, [String fallbackType = 'orange_person']) {
    if (iconUrl.isNotEmpty && iconUrl.startsWith('http')) {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: iconUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => _buildFallbackAvatar(fallbackType),
        ),
      );
    }
    return _buildFallbackAvatar(fallbackType);
  }

  Widget _buildFallbackAvatar(String type) {
    if (type == 'orange_person') {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFFF97316),
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.person, color: Colors.white, size: 30)),
      );
    } else if (type == 'black_female') {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.person_pin, color: Colors.white, size: 30)),
      );
    } else if (type == 'photo_scientist') {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFF38BDF8),
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.science, color: Colors.white, size: 26)),
      );
    } else {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFF6366F1),
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.biotech, color: Colors.white, size: 26)),
      );
    }
  }

  // Block 2 & 3: Solution Showcase (Dynamic & Collapsible)
  Widget _buildSolutionShowcase(BuildContext context, bool isMobile, bool isTablet, ClientPortalDetailsModel? details) {
    if (details == null) return const SizedBox.shrink();

    final hasBlockTwoImage = details.blockTwoImage.trim().isNotEmpty;
    final hasBlockTwoContent = details.blockTwoContent.trim().isNotEmpty;
    final hasBlockTwo = hasBlockTwoImage || hasBlockTwoContent;

    final hasBlockThreeImage = details.blockThreeImage.trim().isNotEmpty;
    final hasBlockThreeContent = details.blockThreeContent.trim().isNotEmpty;
    final hasBlockThree = hasBlockThreeImage || hasBlockThreeContent;

    if (!hasBlockTwo && !hasBlockThree) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 32 : 48),
        vertical: 56,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              // Section 1: Comprehensive Lab Solution
              if (hasBlockTwo) ...[
                if (hasBlockTwoImage)
                  (isMobile || isTablet
                      ? Column(
                          children: [
                            _buildImageCard(details.blockTwoImage),
                            const SizedBox(height: 24),
                            _buildComprehensiveLabSolutionBlock(details, isMobile),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildImageCard(details.blockTwoImage)),
                            const SizedBox(width: 48),
                            Expanded(child: _buildComprehensiveLabSolutionBlock(details, isMobile)),
                          ],
                        ))
                else
                  // Hide image completely when not provided by API
                  _buildComprehensiveLabSolutionBlock(details, isMobile),
              ],

              if (hasBlockTwo && hasBlockThree) const SizedBox(height: 56),

              // Section 2: Heart & Science of Medicine Service
              if (hasBlockThree) ...[
                if (hasBlockThreeImage)
                  (isMobile || isTablet
                      ? Column(
                          children: [
                            _buildImageCard(details.blockThreeImage),
                            const SizedBox(height: 24),
                            _buildContentBlock(
                              details.blockThreeContent,
                              details.blockThreeLink,
                              isMobile,
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildContentBlock(
                                details.blockThreeContent,
                                details.blockThreeLink,
                                isMobile,
                              ),
                            ),
                            const SizedBox(width: 48),
                            Expanded(child: _buildImageCard(details.blockThreeImage)),
                          ],
                        ))
                else
                  // Hide image completely when not provided by API
                  _buildContentBlock(
                    details.blockThreeContent,
                    details.blockThreeLink,
                    isMobile,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComprehensiveLabSolutionBlock(ClientPortalDetailsModel details, bool isMobile) {
    final rawContent = details.blockTwoContent;
    final listItems = _extractListItems(rawContent);
    final paragraphs = _extractParagraphs(rawContent);

    final title = paragraphs.isNotEmpty ? paragraphs[0] : details.blockTwoHeader;
    final subtitle = paragraphs.length > 1 ? paragraphs[1] : '';
    final bodyParagraphs = paragraphs.length > 2 ? paragraphs.sublist(2) : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: isMobile ? 24 : 34,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF18100F),
              height: 1.25,
            ),
          ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: const Color(0xFF14457B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        for (final p in bodyParagraphs) ...[
          const SizedBox(height: 12),
          Text(
            p,
            style: GoogleFonts.montserrat(
              fontSize: 14.5,
              color: const Color(0xFF666666),
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
        if (listItems.isNotEmpty) ...[
          const SizedBox(height: 20),
          // Dynamically parsed checklist from API <li> items
          Column(
            children: listItems.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F9),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Color(0xFF2490EB), size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF18100F),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],

        // Read More button if link is present
        if (details.blockTwoLink.trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _launchUrl(details.blockTwoLink),
            icon: const Icon(Icons.add, size: 14, color: Colors.white),
            label: Text(
              'Read More',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2490EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              elevation: 0,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageCard(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildContentBlock(String rawContent, String link, bool isMobile) {
    final paragraphs = _extractParagraphs(rawContent);
    final title = paragraphs.isNotEmpty ? paragraphs[0] : '';
    final subtitle = paragraphs.length > 1 ? paragraphs[1] : '';
    final bodyParagraphs = paragraphs.length > 2 ? paragraphs.sublist(2) : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: isMobile ? 24 : 34,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF18100F),
              height: 1.25,
            ),
          ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF14457B),
            ),
          ),
        ],
        for (final p in bodyParagraphs) ...[
          const SizedBox(height: 12),
          Text(
            p,
            style: GoogleFonts.montserrat(
              fontSize: 14.5,
              color: const Color(0xFF666666),
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
        if (link.trim().isNotEmpty) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _launchUrl(link),
            icon: const Icon(Icons.add, size: 14, color: Colors.white),
            label: Text(
              'Read More',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2490EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              elevation: 0,
            ),
          ),
        ],
      ],
    );
  } // OUR SERVICES Section (Dynamically Filterable & Equal Height Cards)

  Widget _buildBlockFourServicesSection(BuildContext context, bool isMobile, bool isTablet, ClientPortalDetailsModel? details) {
    final rawServices = details?.services ?? [];
    final services = rawServices.where((s) {
      return s.title.trim().isNotEmpty || s.content.trim().isNotEmpty || s.iconUrl.trim().isNotEmpty || s.link.trim().isNotEmpty;
    }).toList();

    if (services.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 32 : 48),
        vertical: 56,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              // Pill Badge
              if ((details?.blockFourHeaderOne ?? '').trim().isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3E9FB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    details!.blockFourHeaderOne.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2490EB),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if ((details?.blockFourHeaderTwo ?? '').trim().isNotEmpty) ...[
                Text(
                  details!.blockFourHeaderTwo,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: isMobile ? 24 : 38,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF18100F),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 36),
              ],
              isMobile
                  ? Column(
                      children: List.generate(services.length, (index) {
                        final s = services[index];
                        final isEven = index % 2 == 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildServiceCard(s, isEven, isMobile: true),
                        );
                      }),
                    )
                  : isTablet
                      ? Column(
                          children: [
                            for (int r = 0; r < (services.length / 2).ceil(); r++) ...[
                              if (r > 0) const SizedBox(height: 20),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: _buildServiceCard(services[r * 2], (r * 2) % 2 == 0)),
                                    const SizedBox(width: 20),
                                    if (r * 2 + 1 < services.length) Expanded(child: _buildServiceCard(services[r * 2 + 1], (r * 2 + 1) % 2 == 0)) else const Expanded(child: SizedBox()),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        )
                      : Column(
                          children: [
                            for (int r = 0; r < (services.length / 4).ceil(); r++) ...[
                              if (r > 0) const SizedBox(height: 20),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    for (int col = 0; col < 4; col++) ...[
                                      if (col > 0) const SizedBox(width: 20),
                                      if (r * 4 + col < services.length)
                                        Expanded(
                                          child: _buildServiceCard(
                                            services[r * 4 + col],
                                            (r * 4 + col) % 2 == 0,
                                          ),
                                        )
                                      else
                                        const Expanded(child: SizedBox()),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceItemModel s, bool isEven, {bool isMobile = false}) {
    final cleanContent = _cleanHtml(s.content);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBoxAvatar(s.iconUrl, isEven ? 'orange_person' : 'black_female'),
          if (s.title.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              s.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF18100F),
              ),
            ),
          ],
          if (cleanContent.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              cleanContent,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13.5,
                color: const Color(0xFF666666),
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          if (!isMobile) const Spacer(),

          // Read More (only when link is present)
          if (s.link.trim().isNotEmpty) ...[
            InkWell(
              onTap: () => _launchUrl(s.link),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Read More',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2490EB),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.add, size: 14, color: Color(0xFF2490EB)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _extractYouTubeVideoId(String url) {
    if (url.isEmpty) return null;
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  Widget _buildVideoThumbnail(String? videoId, bool isMobile) {
    if (videoId == null || videoId.isEmpty) {
      return Container(
        color: const Color(0xFF0F172A),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_outlined, color: Colors.white38, size: 48),
              const SizedBox(height: 8),
              Text(
                'Video Preview',
                style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    final maxResUrl = 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    final hqUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return CachedNetworkImage(
      imageUrl: maxResUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(color: const Color(0xFF0F172A)),
      errorWidget: (context, url, error) => CachedNetworkImage(
        imageUrl: hqUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(color: const Color(0xFF0F172A)),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFF0F172A),
          child: const Center(
            child: Icon(Icons.play_circle_outline, color: Colors.white38, size: 56),
          ),
        ),
      ),
    );
  }

  // Video Section
  Widget _buildBlockFiveVideoSection(BuildContext context, bool isMobile, ClientPortalDetailsModel? details) {
    if (details == null) return const SizedBox.shrink();

    final header = details.blockFiveHeader.trim();
    final title = details.blockFiveTitle.trim();
    final content = _cleanHtml(details.blockFiveContent).trim();
    final videoLink = details.blockFiveVideoLink.trim();

    // If the YouTube video link is not provided, hide the entire block
    if (videoLink.isEmpty) {
      return const SizedBox.shrink();
    }

    final videoId = _extractYouTubeVideoId(videoLink);

    return Container(
      width: double.infinity,
      color: const Color(0xFF14457B),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 56),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              if (header.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3E9FB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    header.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2490EB),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: isMobile ? 24 : 36,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (videoLink.isNotEmpty) ...[
                InkWell(
                  onTap: () => _launchUrl(videoLink),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: isMobile ? 220 : 380,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 28,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // YouTube Thumbnail Preview
                        Positioned.fill(
                          child: _buildVideoThumbnail(videoId, isMobile),
                        ),

                        // Cinematic Dark Vignette Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.45),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Centered Vector Play Button with Glowing Pulse
                        Container(
                          width: isMobile ? 60 : 76,
                          height: isMobile ? 60 : 76,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2490EB),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2490EB).withOpacity(0.6),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(left: isMobile ? 4 : 5),
                              child: CustomPaint(
                                size: Size(isMobile ? 22 : 28, isMobile ? 22 : 28),
                                painter: _PlayTrianglePainter(color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                        // Top-Right YouTube Badge
                        if (videoId != null)
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF0000),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Center(
                                      child: CustomPaint(
                                        size: const Size(6, 6),
                                        painter: _PlayTrianglePainter(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'YouTube',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Bottom-Left "Watch Video" Subtitle
                        Positioned(
                          bottom: 14,
                          left: 16,
                          child: Row(
                            children: [
                              const Icon(Icons.play_circle_fill, color: Colors.white70, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Click to Watch Video',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (content.isNotEmpty)
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.7,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Client Partners (Dynamically API-Driven & Collapsible)
  Widget _buildClientsSection(BuildContext context, bool isMobile, ClientPortalDetailsModel? details) {
    final clients = details?.clients ?? [];
    if (clients.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 48),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              Text(
                'TRUSTED BY INDUSTRY LEADERS & DIAGNOSTIC LABS',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF666666),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: clients.map((client) {
                  final hasIcon = client.iconUrl.trim().isNotEmpty && client.iconUrl.startsWith('http');

                  return InkWell(
                    onTap: client.link.trim().isNotEmpty ? () => _launchUrl(client.link) : null,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: hasIcon ? 18 : 20,
                        vertical: hasIcon ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: hasIcon
                          ? CachedNetworkImage(
                              imageUrl: client.iconUrl,
                              height: 34,
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) => Text(
                                client.name,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF18100F),
                                ),
                              ),
                            )
                          : Text(
                              client.name,
                              style: GoogleFonts.montserrat(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF18100F),
                              ),
                            ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Executive Multi-Column Footer (100% Dynamic & API-Driven)
  Widget _buildFooterSection(BuildContext context, bool isMobile, bool isTablet, ClientPortalDetailsModel? details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopWidth = screenWidth >= 1024;
    final hasFooterLogo = (details?.footerLogo ?? '').trim().isNotEmpty && details!.footerLogo.startsWith('http');
    final address = (details?.address ?? '').trim();
    final mobile = (details?.mobile ?? '').trim();
    final email = (details?.email ?? '').trim();
    final hasContactInfo = mobile.isNotEmpty || email.isNotEmpty;

    return Container(
      width: double.infinity,
      color: const Color(0xFF14457B),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 48),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              if (!isDesktopWidth) ...[
                // Stacked & wrapped layout for Mobile and Tablet
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasFooterLogo)
                      CachedNetworkImage(
                        imageUrl: details!.footerLogo,
                        height: 36,
                        fit: BoxFit.contain,
                        errorWidget: (c, u, e) => const RevolLogo(fontSize: 24, isDark: true),
                      )
                    else
                      const RevolLogo(fontSize: 24, isDark: true),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        address,
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white.withOpacity(0.85), height: 1.7),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 32,
                      runSpacing: 24,
                      children: [
                        SizedBox(
                          width: isMobile ? double.infinity : 240,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quick Links', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 12),
                              _buildFooterLink('Client Portal Login', widget.onNavigateToLogin),
                            ],
                          ),
                        ),
                        if (hasContactInfo)
                          SizedBox(
                            width: isMobile ? double.infinity : 260,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Contact Info', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 12),
                                if (mobile.isNotEmpty) ...[
                                  _buildFooterContactItem('Phone', mobile),
                                  const SizedBox(height: 8),
                                ],
                                if (email.isNotEmpty) _buildFooterContactItem('Email', email),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _buildNewsletterBox(),
                  ],
                ),
              ] else ...[
                // Desktop 4-Column Layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasFooterLogo)
                            CachedNetworkImage(
                              imageUrl: details!.footerLogo,
                              height: 38,
                              fit: BoxFit.contain,
                              errorWidget: (c, u, e) => const RevolLogo(fontSize: 26, isDark: true),
                            )
                          else
                            const RevolLogo(fontSize: 26, isDark: true),
                          if (address.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              address,
                              style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white.withOpacity(0.85), height: 1.7),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quick Links', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 14),
                          _buildFooterLink('Client Portal Login', widget.onNavigateToLogin),
                        ],
                      ),
                    ),
                    if (hasContactInfo) ...[
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contact Info', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 14),
                            if (mobile.isNotEmpty) ...[
                              _buildFooterContactItem('Phone', mobile),
                              const SizedBox(height: 8),
                            ],
                            if (email.isNotEmpty) _buildFooterContactItem('Email', email),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 3,
                      child: _buildNewsletterBox(),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 36),
              const Divider(color: Colors.white24),
              const SizedBox(height: 18),
              Text(
                'Copyright ©2026 All rights reserved | www.revolsolutions.com',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsletterBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Newsletter',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 240;
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _newsletterEmailController,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _handleNewsletterSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2490EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                    ),
                    child: Text('Sign Up', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newsletterEmailController,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleNewsletterSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2490EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  ),
                  child: Text('Sign Up', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: GoogleFonts.montserrat(fontSize: 14, color: const Color(0xFF93C5FD), fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildFooterContactItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        Expanded(
          child: Text(value, style: GoogleFonts.montserrat(fontSize: 14, color: const Color(0xD9FFFFFF), height: 1.5)),
        ),
      ],
    );
  }
}

class _PlayTrianglePainter extends CustomPainter {
  final Color color;
  _PlayTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.05)
      ..lineTo(size.width * 0.95, size.height * 0.5)
      ..lineTo(size.width * 0.15, size.height * 0.95)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
