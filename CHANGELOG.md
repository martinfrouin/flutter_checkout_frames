# Changelog

## [0.0.1] - 2025-11-19

### Ajouté
- Implémentation initiale du SDK Checkout Frames pour Flutter
- Widget `Frames` principal pour gérer la tokenisation
- Widgets de saisie : `CardNumber`, `ExpiryDate`, `Cvv`
- Widget `SubmitButton` pour déclencher la tokenisation
- Validation en temps réel des champs de carte
- Détection automatique du type de carte (Visa, Mastercard, Amex, etc.)
- Support des informations de titulaire de carte et d'adresse de facturation
- Mode debug avec logs détaillés
- Formatage automatique du numéro de carte et de la date d'expiration
- Support des environnements sandbox et production
- Callbacks pour tous les événements (validation, tokenisation, etc.)
- Documentation complète en français
- Application d'exemple avec interface moderne
- Adapté depuis le projet frames-react-native de Checkout.com

### Fonctionnalités
- 🔒 Tokenisation sécurisée des cartes via l'API Checkout.com
- 🎨 Widgets Flutter entièrement personnalisables
- ✅ Validation Luhn des numéros de carte
- 🌍 Support de toutes les principales cartes de crédit/débit
- 📱 Interface responsive et moderne
- 🐛 Mode debug pour faciliter le développement
- 🔄 Détection automatique du BIN (Bank Identification Number)
