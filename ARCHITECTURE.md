# Architecture du projet Checkout Frames Flutter

## 📁 Structure du projet

```
checkout_frames/
├── lib/
│   ├── checkout_frames.dart          # Point d'entrée principal (exports publics)
│   └── src/
│       ├── models/                    # Modèles de données
│       │   ├── frames_config.dart     # Configuration (FramesConfig, Cardholder, BillingAddress)
│       │   ├── card_token.dart        # Réponse de tokenisation (CardTokenResponse, CardTokenizationFailure)
│       │   └── card_validation.dart   # État de validation (FieldValidation, CardValidationState, PaymentMethod)
│       ├── services/                  # Services
│       │   └── checkout_api_service.dart  # Communication avec l'API Checkout.com
│       ├── utils/                     # Utilitaires
│       │   └── card_validator.dart    # Validation et formatage des cartes
│       └── widgets/                   # Composants UI
│           ├── frames.dart            # Widget principal Frames
│           ├── frames_provider.dart   # Provider pour la gestion d'état
│           ├── card_number_field.dart # Champ numéro de carte
│           ├── expiry_date_field.dart # Champ date d'expiration
│           ├── cvv_field.dart         # Champ CVV
│           └── submit_button.dart     # Bouton de soumission
├── test/
│   └── checkout_frames_test.dart      # Tests unitaires
├── example/
│   ├── lib/
│   │   └── main.dart                  # Application d'exemple
│   └── pubspec.yaml
├── pubspec.yaml                       # Dépendances du package
├── README.md                          # Documentation principale
├── CHANGELOG.md                       # Journal des modifications
├── MIGRATION_FROM_RN.md              # Guide de migration depuis React Native
└── ARCHITECTURE.md                   # Ce fichier
```

## 🏗️ Architecture en couches

### 1. Couche de présentation (Widgets)

**Responsabilité** : Afficher l'interface utilisateur et capturer les interactions

- `Frames` : Widget racine qui orchestre l'ensemble
- `CardNumber`, `ExpiryDate`, `Cvv` : Champs de saisie spécialisés
- `SubmitButton` : Déclenche la tokenisation

**Pattern** : Widget Tree + InheritedWidget pour la propagation d'état

### 2. Couche de gestion d'état (Provider)

**Responsabilité** : Gérer l'état partagé entre les widgets

- `FramesProvider` : InheritedWidget pour accès à l'état
- `FramesState` : ChangeNotifier qui contient l'état

**État géré** :
- Valeurs des champs (cardNumber, expiryMonth, expiryYear, cvv)
- État de validation de chaque champ
- Méthode de paiement détectée
- Callbacks pour les événements

### 3. Couche métier (Utils)

**Responsabilité** : Logique de validation et formatage

- `CardValidator` :
  - Validation Luhn
  - Détection du type de carte
  - Validation des dates d'expiration
  - Validation CVV
  - Formatage automatique

### 4. Couche de service (Services)

**Responsabilité** : Communication avec les API externes

- `CheckoutApiService` :
  - Tokenisation des cartes
  - Sélection automatique de l'environnement (sandbox/production)
  - Gestion des erreurs

### 5. Couche de données (Models)

**Responsabilité** : Structures de données typées

- Configuration : `FramesConfig`, `Cardholder`, `BillingAddress`
- Réponses : `CardTokenResponse`, `CardTokenizationFailure`
- Validation : `FieldValidation`, `CardValidationState`, `PaymentMethod`

## 🔄 Flux de données

### Flux de validation

```
User Input
    ↓
TextField (CardNumber/ExpiryDate/Cvv)
    ↓
_onTextChanged()
    ↓
CardValidator.validate*()
    ↓
FramesState.update*Validation()
    ↓
Callbacks (frameValidationChanged, cardValidationChanged)
    ↓
UI Update (SubmitButton enabled/disabled)
```

### Flux de tokenisation

```
User clicks SubmitButton
    ↓
context.submitFramesCard()
    ↓
FramesWidgetState.submitCard()
    ↓
Validation check
    ↓
CheckoutApiService.tokenizeCard()
    ↓
HTTP POST to Checkout.com API
    ↓
Success: cardTokenized callback
    ↓
Failure: cardTokenizationFailed callback
```

## 🎯 Patterns de conception utilisés

### 1. **Provider Pattern** (InheritedWidget)
- Partage d'état entre widgets sans prop drilling
- `FramesProvider` donne accès à `FramesState`

### 2. **Observer Pattern** (ChangeNotifier)
- `FramesState` notifie les widgets des changements
- Les widgets se reconstruisent automatiquement

### 3. **Strategy Pattern**
- Différentes stratégies de validation selon le type de carte
- Format différent pour Amex (4-6-5) vs autres (4-4-4-4)

### 4. **Builder Pattern**
- `FramesConfig` pour construire la configuration
- Permet des configurations optionnelles élégantes

### 5. **Facade Pattern**
- `Frames` cache la complexité de la gestion d'état
- API simple pour l'utilisateur final

## 🔐 Gestion de la sécurité

### Données sensibles

1. **Numéro de carte** :
   - Stocké temporairement en mémoire dans `FramesState`
   - Jamais persisté sur le disque
   - Effacé après tokenisation

2. **CVV** :
   - Masqué dans le TextField (obscureText: true)
   - Jamais loggé même en mode debug
   - Effacé après tokenisation

3. **Token** :
   - Retourné via callback
   - Responsabilité de l'app de le gérer

### Communication

- HTTPS obligatoire (géré par l'API Checkout.com)
- Clé publique dans les headers
- Pas de stockage de secrets côté client

## 🧪 Tests

### Tests unitaires (test/checkout_frames_test.dart)

1. **CardValidator** :
   - Validation de numéros de carte valides/invalides
   - Détection des types de carte
   - Validation des dates d'expiration
   - Validation CVV
   - Formatage

2. **FramesConfig** :
   - Création avec champs requis
   - Création avec cardholder

3. **CardValidationState** :
   - États valide/invalide
   - Mise à jour de champs individuels

### Tests d'intégration (example/lib/main.dart)

- Application complète démontrant l'utilisation
- Interface utilisateur testable manuellement
- Cartes de test fournies

## 🚀 Performance

### Optimisations

1. **Validation incrémentale** :
   - Validation uniquement quand les champs changent
   - Pas de revalidation inutile

2. **Formatage on-the-fly** :
   - Formatage pendant la saisie
   - Évite le reformatage complet

3. **Détection de type de carte** :
   - Algorithme O(1) basé sur les préfixes
   - Pas de regex complexes

4. **État local** :
   - Chaque champ gère son propre TextEditingController
   - Minimise les rebuilds

## 📦 Dépendances

### Principales

- `flutter` : Framework UI
- `http: ^1.2.0` : Requêtes HTTP vers l'API Checkout.com

### Dev

- `flutter_test` : Tests unitaires
- `flutter_lints: ^5.0.0` : Linting et analyse statique

## 🔮 Évolutions futures possibles

1. **Support des wallets** : Apple Pay, Google Pay
2. **Biométrie** : Authentification biométrique
3. **3D Secure** : Support natif du 3DS
4. **Thèmes** : Thèmes prédéfinis (dark, light, custom)
5. **i18n** : Internationalisation des messages d'erreur
6. **Animations** : Transitions et feedback visuels
7. **Accessibility** : Support complet WCAG
8. **Platform channels** : Intégration native iOS/Android pour fonctionnalités avancées

## 📚 Ressources complémentaires

- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Checkout.com API Documentation](https://docs.checkout.com/)
