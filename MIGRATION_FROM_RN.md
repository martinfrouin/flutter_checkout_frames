# Migration de React Native vers Flutter

Ce document compare l'implémentation React Native de Checkout Frames avec la version Flutter.

## 🔄 Correspondance des composants

### React Native → Flutter

| React Native | Flutter | Notes |
|-------------|---------|-------|
| `Frames` | `Frames` | Widget wrapper principal |
| `CardNumber` | `CardNumber` | Champ numéro de carte |
| `ExpiryDate` | `ExpiryDate` | Champ date d'expiration |
| `Cvv` | `Cvv` | Champ CVV |
| `SubmitButton` | `SubmitButton` | Bouton de soumission |

## 📝 Différences de syntaxe

### Configuration

**React Native:**
```javascript
<Frames
  config={{
    debug: true,
    publicKey: "pk_sbox_...",
  }}
  cardTokenized={(e) => {
    alert(e.token);
  }}
>
```

**Flutter:**
```dart
Frames(
  config: FramesConfig(
    debug: true,
    publicKey: 'pk_sbox_...',
  ),
  cardTokenized: (token) {
    print(token.token);
  },
  child: Column(
    children: [
      // ...
    ],
  ),
)
```

### Styles

**React Native:**
```javascript
<CardNumber
  style={styles.cardNumber}
  placeholderTextColor="#9898A0"
/>

const styles = StyleSheet.create({
  cardNumber: {
    fontSize: 18,
    height: 50,
    color: "#FEFFFF",
    backgroundColor: "#1B1C1E",
  },
});
```

**Flutter:**
```dart
CardNumber(
  style: TextStyle(
    fontSize: 18,
    color: Color(0xFFFEFFFF),
  ),
  placeholderTextColor: Color(0xFF9898A0),
  decoration: InputDecoration(
    filled: true,
    fillColor: Color(0xFF1B1C1E),
  ),
)
```

### Layout

**React Native:**
```javascript
<View style={styles.dateAndCode}>
  <ExpiryDate style={styles.expiryDate} />
  <Cvv style={styles.cvv} />
</View>

const styles = StyleSheet.create({
  dateAndCode: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  expiryDate: {
    width: '48%',
  },
});
```

**Flutter:**
```dart
Row(
  children: [
    Expanded(
      child: ExpiryDate(),
    ),
    SizedBox(width: 15),
    Expanded(
      child: Cvv(),
    ),
  ],
)
```

## 🔧 Props / Paramètres

### CardNumber

| React Native | Flutter | Type |
|-------------|---------|------|
| `style` | `style` | `TextStyle?` |
| `placeholderTextColor` | `placeholderTextColor` | `Color?` |
| `showIcon` | `showIcon` | `bool` |
| - | `decoration` | `InputDecoration?` |
| - | `focusNode` | `FocusNode?` |

### Callbacks

**React Native:**
```javascript
cardTokenized={(e) => {
  console.log(e.token);
  console.log(e.scheme);
  console.log(e.last4);
}}
```

**Flutter:**
```dart
cardTokenized: (token) {
  print(token.token);
  print(token.scheme);
  print(token.last4);
}
```

## 🎯 Fonctionnalités identiques

✅ Validation Luhn des numéros de carte
✅ Détection automatique du type de carte
✅ Formatage automatique (espaces dans le numéro de carte)
✅ Validation en temps réel
✅ Support des environnements sandbox/production
✅ Callbacks pour tous les événements
✅ Informations BIN
✅ Support du cardholder et billing address

## 🆕 Améliorations Flutter

1. **Type safety** : Types Dart fortement typés
2. **Null safety** : Protection contre les valeurs null
3. **InputDecoration** : Personnalisation avancée des champs
4. **FocusNode** : Gestion avancée du focus
5. **Tests unitaires** : Suite de tests complète incluse
6. **Documentation** : Documentation inline avec DartDoc

## 📱 Exemple complet de migration

### React Native (Original)

```javascript
import React from "react";
import { StyleSheet, View } from "react-native";
import {
  Frames,
  CardNumber,
  ExpiryDate,
  Cvv,
  SubmitButton,
} from "frames-react-native";

export default function App() {
  return (
    <View style={styles.container}>
      <Frames
        config={{
          debug: true,
          publicKey: "pk_sbox_...",
        }}
        cardTokenized={(e) => {
          alert(e.token);
        }}
      >
        <CardNumber
          style={styles.cardNumber}
          placeholderTextColor="#9898A0"
        />

        <View style={styles.dateAndCode}>
          <ExpiryDate
            style={styles.expiryDate}
            placeholderTextColor="#9898A0"
          />
          <Cvv style={styles.cvv} placeholderTextColor="#9898A0" />
        </View>

        <SubmitButton
          title="Pay Now"
          style={styles.button}
          textStyle={styles.buttonText}
        />
      </Frames>
    </View>
  );
}
```

### Flutter (Adapté)

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
            debug: true,
            publicKey: 'pk_sbox_...',
          ),
          cardTokenized: (token) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Success'),
                content: Text(token.token),
              ),
            );
          },
          child: Column(
            children: [
              CardNumber(
                style: TextStyle(fontSize: 18),
                placeholderTextColor: Color(0xFF9898A0),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ExpiryDate(
                      style: TextStyle(fontSize: 18),
                      placeholderTextColor: Color(0xFF9898A0),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Cvv(
                      style: TextStyle(fontSize: 18),
                      placeholderTextColor: Color(0xFF9898A0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SubmitButton(
                title: 'Pay Now',
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4285F4),
                ),
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 🚀 Points d'attention lors de la migration

1. **Imports** : `import 'package:checkout_frames/checkout_frames.dart';`
2. **Styles** : Utiliser `TextStyle` au lieu de style objects
3. **Couleurs** : `Color(0xFFRRGGBB)` au lieu de `"#RRGGBB"`
4. **Layout** : `Column`/`Row` au lieu de `View` avec flexDirection
5. **Callbacks** : Syntaxe Dart `(param) => { }` au lieu de `(param) => { }`
6. **Async** : Utiliser `async`/`await` pour les appels API

## 📚 Ressources

- [Documentation Flutter](https://flutter.dev/docs)
- [Checkout.com API](https://docs.checkout.com/)
- [Frames React Native (original)](https://github.com/checkout/frames-react-native)
