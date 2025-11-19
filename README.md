# Checkout Frames Flutter

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

SDK Flutter pour Checkout.com Frames - Acceptez les paiements par carte de manière sécurisée avec des champs de saisie personnalisables et une tokenisation.

Adapté de [frames-react-native](https://github.com/checkout/frames-react-native) pour Flutter.

## 🤓 Comment ça fonctionne ?

L'acceptation des paiements par carte comporte généralement 2 étapes principales :

1. **Collecte sécurisée des détails de carte** (côté client) - C'est le rôle de Frames
2. **Traitement du paiement** via l'API (côté serveur) - Utilisez les SDK serveur de Checkout.com

Frames tokenise les informations sensibles et vous renvoie un jeton sécurisé (avec diverses métadonnées de carte, comme les informations BIN).

> Frames est conçu pour être utilisé avec le reste des éléments de votre page de paiement, vous donnant un contrôle total sur l'interface utilisateur.

## 🚀 Installation

Ajoutez cette dépendance à votre fichier `pubspec.yaml` :

```yaml
dependencies:
  checkout_frames: ^0.0.1
  # ou depuis un chemin local :
  # checkout_frames:
  #   path: ../checkout_frames
```

Puis exécutez :

```bash
flutter pub get
```

## 💻 Importation

```dart
import 'package:checkout_frames/checkout_frames.dart';
```

## 🎉 Exemple d'utilisation

### Exemple simple

```dart
import 'package:flutter/material.dart';
import 'package:checkout_frames/checkout_frames.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Frames(
          config: FramesConfig(
            publicKey: 'pk_sbox_eo3yb3urja2ozf6ycgn5kuy7ke4',
            debug: true,
          ),
          cardTokenized: (token) {
            print('Token: ${token.token}');
            // Utilisez ce token pour traiter le paiement côté serveur
          },
          cardTokenizationFailed: (error) {
            print('Error: ${error.message}');
          },
          child: Column(
            children: [
              CardNumber(
                style: TextStyle(fontSize: 18),
                placeholderTextColor: Colors.grey,
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ExpiryDate(
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Cvv(
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SubmitButton(
                title: 'Payer maintenant',
                onPress: () => print('Traitement du paiement...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Exemple avec personnalisation complète

```dart
Frames(
  config: FramesConfig(
    publicKey: 'pk_sbox_...',
    debug: true,
    cardholder: Cardholder(
      name: 'John Doe',
      phone: '+33612345678',
      billingAddress: BillingAddress(
        addressLine1: '123 Rue de la Paix',
        addressLine2: 'Appartement 4B',
        city: 'Paris',
        zip: '75001',
        state: 'Île-de-France',
        country: 'FR',
      ),
    ),
  ),
  cardTokenized: (token) {
    print('Token: ${token.token}');
    print('Scheme: ${token.scheme}');
    print('Last 4: ${token.last4}');
  },
  cardTokenizationFailed: (error) {
    print('Erreur: ${error.message}');
  },
  paymentMethodChanged: (event) {
    print('Méthode de paiement: ${event.scheme}');
  },
  cardValidationChanged: (state) {
    print('Validation: ${state.isValid}');
  },
  cardBinChanged: (binInfo) {
    print('BIN: ${binInfo.bin}');
  },
  child: Column(
    children: [
      CardNumber(
        decoration: InputDecoration(
          hintText: 'Numéro de carte',
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      // ... autres champs
    ],
  ),
)
```

## 🎨 Composants

### Frames (Wrapper)

Le composant principal qui enveloppe tous les champs de carte.

**Props:**

| Propriété                | Type                                              | Description                                                  |
| ------------------------ | ------------------------------------------------- | ------------------------------------------------------------ |
| `config`                 | `FramesConfig`                                    | Configuration (clé publique, debug, cardholder)              |
| `child`                  | `Widget`                                          | Widgets enfants (CardNumber, ExpiryDate, Cvv, SubmitButton) |
| `cardTokenized`          | `Function(CardTokenResponse)`                     | Callback appelé après la tokenisation réussie                |
| `cardTokenizationFailed` | `Function(CardTokenizationFailure)`               | Callback appelé en cas d'échec de la tokenisation            |
| `frameValidationChanged` | `Function(FieldValidation, String)`               | Appelé quand la validation d'un champ change                 |
| `paymentMethodChanged`   | `Function(PaymentMethodChanged)`                  | Appelé quand une méthode de paiement valide est détectée     |
| `cardValidationChanged`  | `Function(CardValidationState)`                   | Appelé quand l'état de validation de la carte change         |
| `cardBinChanged`         | `Function(CardBinInfo)`                           | Appelé quand les 6-8 premiers chiffres changent              |

### CardNumber

Champ de saisie pour le numéro de carte.

**Props:**

| Propriété              | Type              | Description                             |
| ---------------------- | ----------------- | --------------------------------------- |
| `style`                | `TextStyle?`      | Style du texte                          |
| `placeholder`          | `String?`         | Texte d'indication                      |
| `placeholderTextColor` | `Color?`          | Couleur du texte d'indication           |
| `showIcon`             | `bool`            | Afficher l'icône du schéma de carte     |
| `decoration`           | `InputDecoration?`| Décoration personnalisée du champ       |
| `focusNode`            | `FocusNode?`      | Node de focus personnalisé              |

### ExpiryDate

Champ de saisie pour la date d'expiration (MM/YY).

**Props:**

| Propriété              | Type              | Description                             |
| ---------------------- | ----------------- | --------------------------------------- |
| `style`                | `TextStyle?`      | Style du texte                          |
| `placeholder`          | `String?`         | Texte d'indication (défaut: "MM/YY")   |
| `placeholderTextColor` | `Color?`          | Couleur du texte d'indication           |
| `decoration`           | `InputDecoration?`| Décoration personnalisée du champ       |
| `focusNode`            | `FocusNode?`      | Node de focus personnalisé              |

### Cvv

Champ de saisie pour le CVV (3 chiffres, 4 pour Amex).

**Props:**

| Propriété              | Type              | Description                             |
| ---------------------- | ----------------- | --------------------------------------- |
| `style`                | `TextStyle?`      | Style du texte                          |
| `placeholder`          | `String?`         | Texte d'indication (défaut: "CVV")     |
| `placeholderTextColor` | `Color?`          | Couleur du texte d'indication           |
| `decoration`           | `InputDecoration?`| Décoration personnalisée du champ       |
| `focusNode`            | `FocusNode?`      | Node de focus personnalisé              |

### SubmitButton

Bouton de soumission pour déclencher la tokenisation.

**Props:**

| Propriété   | Type          | Description                                      |
| ----------- | ------------- | ------------------------------------------------ |
| `title`     | `String`      | Texte du bouton                                  |
| `style`     | `ButtonStyle?`| Style du bouton                                  |
| `textStyle` | `TextStyle?`  | Style du texte                                   |
| `onPress`   | `VoidCallback?`| Action supplémentaire avant la tokenisation    |
| `enabled`   | `bool?`       | Forcer l'état activé/désactivé                   |

## 📋 Configuration

### FramesConfig

```dart
FramesConfig(
  publicKey: 'pk_sbox_...', // Votre clé publique Checkout.com
  debug: true, // Mode debug (affiche les logs)
  cardholder: Cardholder(
    name: 'John Doe',
    phone: '+33612345678',
    billingAddress: BillingAddress(
      addressLine1: '123 Rue de la Paix',
      city: 'Paris',
      zip: '75001',
      country: 'FR',
    ),
  ),
)
```

### Cardholder (optionnel)

Informations sur le titulaire de la carte :

- `name` : Nom du titulaire
- `phone` : Numéro de téléphone
- `billingAddress` : Adresse de facturation

### BillingAddress (optionnel)

- `addressLine1` : Ligne d'adresse 1
- `addressLine2` : Ligne d'adresse 2
- `city` : Ville
- `zip` : Code postal
- `state` : État/Région
- `country` : Code pays (ISO 3166-1 alpha-2, ex: "FR", "GB", "US")

## 🧪 Cartes de test

Pour tester dans l'environnement sandbox :

| Type             | Numéro                |
| ---------------- | --------------------- |
| Visa             | 4242 4242 4242 4242   |
| Mastercard       | 5436 0310 3060 6378   |
| American Express | 3782 822463 10005     |

Utilisez n'importe quelle date d'expiration future (ex: 12/25) et n'importe quel CVV (3 chiffres, 4 pour Amex).

## 🔒 Sécurité

- Les détails de carte ne sont **jamais** stockés localement
- Toutes les communications avec l'API Checkout.com sont chiffrées (HTTPS)
- Seul un token sécurisé est retourné à votre application
- Le token doit être utilisé côté serveur pour traiter le paiement

## 🌐 Environnements

- **Sandbox** : Clés commençant par `pk_sbox_` ou `pk_test_`
- **Production** : Clés commençant par `pk_`

L'URL de l'API est automatiquement sélectionnée en fonction de votre clé publique.

## 📖 Ressources

- [Documentation Checkout.com](https://docs.checkout.com/)
- [Frames React Native (original)](https://github.com/checkout/frames-react-native)
- [API Tokens](https://docs.checkout.com/docs/tokenize-card-details)

## 📄 Licence

MIT License - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

## 🙏 Remerciements

Ce projet est une adaptation Flutter du projet [frames-react-native](https://github.com/checkout/frames-react-native) de Checkout.com.
