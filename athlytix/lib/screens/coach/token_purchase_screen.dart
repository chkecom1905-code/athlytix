import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/user_model.dart';
import '../../services/token_service.dart';

class TokenPurchaseScreen extends StatefulWidget {
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;

  const TokenPurchaseScreen({super.key, required this.profile, required this.onUpdate});

  @override State<TokenPurchaseScreen> createState() => _TokenPurchaseScreenState();
}

class _TokenPurchaseScreenState extends State<TokenPurchaseScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedPack;
  bool _loading = false;
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 300));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _purchase(int packIndex) async {
    HapticFeedback.mediumImpact();
    setState(() { _selectedPack = packIndex; _loading = true; });

    // TODO: Stripe payment here
    // For now, simulate a successful purchase (demo)
    await Future.delayed(const Duration(seconds: 2));

    final pack = TokenService.packs[packIndex];
    final newTokens = await TokenService.addTokens(pack.tokens);

    if (mounted) {
      final updated = widget.profile?.copyWith(aiTokens: newTokens);
      if (updated != null) widget.onUpdate(updated);

      setState(() { _loading = false; _selectedPack = null; });

      _showSuccess(pack);
    }
  }

  void _showSuccess(TokenPack pack) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SuccessSheet(pack: pack, onDone: () {
        Navigator.pop(context);
        Navigator.pop(context);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.card, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border)),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18))),
            title: Text('Tokens Coach IA', style: AppTextStyles.heading3),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                _hero(),
                const SizedBox(height: 28),
                ...TokenService.packs.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _PackCard(
                      pack: e.value,
                      index: e.key,
                      isSelected: _selectedPack == e.key,
                      loading: _loading && _selectedPack == e.key,
                      onTap: _loading ? null : () => _purchase(e.key),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _faqSection(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    final tokens = widget.profile?.aiTokens ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0A3A), Color(0xFF060610)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3))),
      child: Column(children: [
        const Text('✨', style: TextStyle(fontSize: 52)),
        const SizedBox(height: 12),
        ShaderMask(
          shaderCallback: (b) => AppColors.purpleGradient.createShader(b),
          child: Text('Coach IA', style: GoogleFonts.inter(
            fontSize: 32, fontWeight: FontWeight.w900,
            color: Colors.white, letterSpacing: -1))),
        const SizedBox(height: 8),
        Text('Analyse personnalisée · Plans sur mesure · Conseils d\'élite',
          style: AppTextStyles.body, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.secondaryGlow, borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('✨', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text('$tokens token${tokens > 1 ? "s" : ""} restant${tokens > 1 ? "s" : ""}',
              style: TextStyle(color: AppColors.secondary,
                fontSize: 15, fontWeight: FontWeight.w800)),
          ]),
        ),
      ]),
    );
  }

  Widget _faqSection() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.card, borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Comment ça marche ?', style: AppTextStyles.heading3),
      const SizedBox(height: 12),
      ...[
        ('✨', '1 token = 1 analyse IA personnalisée'),
        ('♾️', 'Les tokens n\'expirent jamais'),
        ('🔒', 'Paiement sécurisé via Stripe'),
        ('📱', 'Utilisable sur tous vos appareils'),
      ].map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text(e.$1, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(child: Text(e.$2, style: AppTextStyles.body.copyWith(fontSize: 13))),
        ]),
      )),
    ]),
  );
}

class _PackCard extends StatelessWidget {
  final TokenPack pack;
  final int index;
  final bool isSelected;
  final bool loading;
  final VoidCallback? onTap;

  const _PackCard({
    required this.pack,
    required this.index,
    required this.isSelected,
    required this.loading,
    this.onTap,
  });

  static const _highlights = [
    null,
    'POPULAIRE ⭐',  // M
    'MEILLEUR PRIX 🔥',  // L
  ];

  static const _gradients = [
    AppColors.purpleGradient,
    AppColors.orangeGradient,
    AppColors.orangeGlow,
  ];

  @override
  Widget build(BuildContext context) {
    final highlight = _highlights[index];
    final ppt = (pack.price / pack.tokens * 100).toStringAsFixed(1);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
              ? AppColors.primary
              : index == 1 ? AppColors.primary.withOpacity(0.4) : AppColors.border,
            width: isSelected ? 2 : 1),
          boxShadow: index == 1 ? AppColors.orangeShadow : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (highlight != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: _gradients[index],
                  borderRadius: BorderRadius.circular(6)),
                child: Text(highlight, style: const TextStyle(
                  color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
              const SizedBox(height: 10),
            ],
            Row(children: [
              ShaderMask(
                shaderCallback: (b) => _gradients[index].createShader(b),
                child: Text(pack.label, style: GoogleFonts.inter(
                  fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white))),
              const Spacer(),
              Text(pack.priceLabel, style: GoogleFonts.inter(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: _gradients[index].scale(0.15),
                  borderRadius: BorderRadius.circular(8)),
                child: Text('✨ ${pack.tokens} tokens',
                  style: TextStyle(
                    color: index == 0 ? AppColors.secondary : AppColors.primary,
                    fontSize: 14, fontWeight: FontWeight.w800))),
              if (pack.bonus.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.successGlow,
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(pack.bonus, style: const TextStyle(
                    color: AppColors.success, fontSize: 11,
                    fontWeight: FontWeight.w800))),
              ],
              const Spacer(),
              Text('$ppt¢/analyse',
                style: AppTextStyles.caption),
            ]),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity, height: 46,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _gradients[index],
                  borderRadius: BorderRadius.circular(14)),
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
                  child: loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : Text('Acheter ${pack.label}', style: const TextStyle(
                        color: Colors.white, fontSize: 14,
                        fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessSheet extends StatelessWidget {
  final TokenPack pack;
  final VoidCallback onDone;
  const _SuccessSheet({required this.pack, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.success.withOpacity(0.4))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎉', style: TextStyle(fontSize: 52)),
        const SizedBox(height: 14),
        Text('Achat réussi !', style: AppTextStyles.heading2),
        const SizedBox(height: 8),
        Text('${pack.tokens} tokens ✨ ajoutés à votre compte',
          style: AppTextStyles.body, textAlign: TextAlign.center),
        const SizedBox(height: 22),
        GradientButton(
          label: 'Utiliser le Coach IA',
          gradient: AppColors.purpleGradient,
          shadows: AppColors.purpleShadow,
          onTap: onDone),
      ]),
    );
  }
}
