import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  //en,fr,es,de
  static var _t = Translations("en") +
      {
        "en": "Products",
        "fr": "Des produits",
        "es": "Productos",
        "de": "Produkte",
        "pt": "Produtos",
        "ar": "منتجات",
        "ko": "제품"
      } +
      {
        "en": "Vendor",
        "fr": "Vendeur",
        "es": "Vendedor",
        "de": "Verkäufer",
        "pt": "Fornecedor",
        "ar": "بائع",
        "ko": "공급 업체"
      } +
      {
        "en": "Orders",
        "fr": "Ordres",
        "es": "Pedidos",
        "de": "Aufträge",
        "pt": "Pedidos",
        "ar": "أوامر",
        "ko": "명령"
      } +
      {
        "en": "More",
        "fr": "Suite",
        "es": "Más",
        "de": "Mehr",
        "pt": "Mais",
        "ar": "أكثر",
        "ko": "더"
      } +
      {
        "en": "Pricing",
        "fr": "Prix",
        "es": "Precios",
        "de": "Preisgestaltung",
        "pt": "Preços",
        "ar": "التسعير",
        "ko": "가격"
      } +
      {
        "en": "Press back again to close",
        "fr": "Appuyez à nouveau pour fermer",
        "es": "Presione de nuevo para cerrar",
        "de": "Zum Schließen erneut drücken",
        "pt": "Pressione novamente para fechar",
        "ar": "اضغط مرة أخرى للإغلاق",
        "ko": "닫으려면 뒤로를 다시 누르세요.",
        "my": "ပိတ်ရန်နောက်သို့ပြန်နှိပ်ပါ"
      };

  String get i18n => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);
}
