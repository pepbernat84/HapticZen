# Haptic Zen — App Store Connect Metadata & Release Guide

Document de referència preparat per copiar i enganxar directament a **App Store Connect**.

---

## 1. Configuració General de l'App

* **Nom de l'App**: `Haptic Zen`
* **Bundle ID (App principal)**: `com.hapticzen.app`
* **Bundle ID (Widget Extension)**: `com.hapticzen.app.widget`
* **App Group**: `group.com.hapticzen`
* **Categoria principal**: Health & Fitness
* **Categoria secundària**: Lifestyle
* **Edat (Age Rating)**: 4+ (sense contingut restringit)
* **Copyright**: `© 2026 Haptic Zen`
* **Encriptació (`ITSAppUsesNonExemptEncryption`)**: `NO` (ja declarat a `Info.plist`)

### Configuració ràpida de signatura per a dispositiu i TestFlight
Un cop tinguis el teu Team ID d'Apple Developer (10 caràcters alfanumèrics), executa:

```bash
python3 generate_project.py --team-id EL_TEU_TEAM_ID
```

Aquest valor es conservarà automàticament en futures regeneracions de `project.pbxproj`. Per a compilacions sense compte de pagament al simulador, pots netejar-lo amb `--team-id ""`.

---

## 2. Fitxes Localitzades (App Store Connect)

> Nota: App Store Connect suporta català dins l'idioma **Catalan** (`ca`), espanyol dins **Spanish (Spain)** (`es-ES`), i anglès dins **English (U.S.)** / **English (U.K.)** (`en-US`).

### 🟡 Català (`ca`)

* **Subtítol** *(màx. 30 caràcters)*:
  `Mindfulness Tàctil i ASMR` *(25 caràcters)*

* **Text promocional** *(màx. 170 caràcters)*:
  `Transforma el teu iPhone en un refugi tàctil. Sent textures realistes amb el Taptic Engine, respira amb guia hàptica i sincronitza minuts de calma amb Apple Health.` *(163 caràcters)*

* **Paraules clau** *(màx. 100 caràcters)*:
  `hàptic,asmr,mindfulness,relaxació,calma,respiració,tàctil,estrès,ansietat,meditació,zen,son` *(91 caràcters)*

* **Descripció**:
  ```text
  Haptic Zen converteix el teu iPhone en una experiència sensorial dissenyada per reduir l'estrès, calmar l'ansietat i recuperar el focus mitjançant el tacte i el so.

  DISSENYAT PER AL TAPTIC ENGINE
  Llisca el dit per un llenç fosc i minimalista i sent com la pantalla respon en temps real a la velocitat i el ritme del teu moviment amb patrons Core Haptics d'alta precisió i àudio espacial ASMR:
  • Bambolles de plàstic (Bubble Wrap) — gratuïta
  • Sorra cinètica (Kinetic Sand) — gratuïta
  • Màquina d'escriure (Typewriter) — Paquet Mecànic
  • Engranatges (Gears) — Paquet Mecànic
  • Pluja intensa (Heavy Rain) — Paquet Natural
  • Petjades a la neu (Stepping Snow) — Paquet Natural

  RESPIRACIÓ GUIADA HÀPTICA
  Tanca els ulls i segueix el ritme amb el dit sobre la pantalla. El motor hàptic modula la intensitat de forma progressiva per guiar cada fase de quatre tècniques provades:
  • Calma 4-2-6-2 (Paced) per activar la resposta parasimpàtica
  • Respiració quadrada 4-4-4-4 (Box Breathing) per a concentració
  • Tècnica 4-7-8 per a relaxació profunda i descans
  • Coherència ressonant 5-0-5-0 per a equilibri HRV

  PAISATGES SONORS I PERSONALITZACIÓ
  • 5 paisatges sonors continus generats en estèreo (Jardí Zen, Ressonància Còsmica, Bols Tibetans, Riuet del Bosc i Pluja Nocturna).
  • Ajust fi d'intensitat hàptica, nitidesa, volum, sensibilitat tonal i estil visual (Ones, Partícules o Ombra).
  • Objectiu diari personalitzable (de 5 a 60 minuts) sincronitzat amb els widgets de la pantalla d'inici i de bloqueig.
  • Integració opcional amb Apple Health (Mindful Minutes).

  PRIVADESA ABSOLUTA
  Sense comptes, sense anuncis i sense seguiment. Les teves preferències i el progrés diari es queden exclusivament al teu dispositiu.
  ```

---

### 🔴 Castellà (`es-ES`)

* **Subtítol** *(màx. 30 caràcters)*:
  `Mindfulness Táctil y ASMR` *(25 caràcters)*

* **Text promocional** *(màx. 170 caràcters)*:
  `Convierte tu iPhone en un refugio táctil. Siente texturas realistas con el Taptic Engine, respira con guía háptica y registra tus minutos de calma en Apple Health.` *(161 caràcters)*

* **Paraules clau** *(màx. 100 caràcters)*:
  `háptico,asmr,mindfulness,relajación,calma,respiración,táctil,estrés,ansiedad,meditación,zen,sueño` *(96 caràcters)*

* **Descripció**:
  ```text
  Haptic Zen convierte tu iPhone en una experiencia sensorial diseñada para reducir el estrés, calmar la ansiedad y recuperar el enfoque a través del tacto y el sonido.

  DISEÑADO PARA EL TAPTIC ENGINE
  Desliza el dedo por un lienzo oscuro y minimalista y siente cómo la pantalla responde en tiempo real a la velocidad y al ritmo de tu movimiento con patrones Core Haptics de alta precisión y audio espacial ASMR:
  • Papel de burbujas (Bubble Wrap) — gratuita
  • Arena cinética (Kinetic Sand) — gratuita
  • Máquina de escribir (Typewriter) — Paquete Mecánico
  • Engranajes (Gears) — Paquete Mecánico
  • Lluvia intensa (Heavy Rain) — Paquete Naturaleza
  • Pisadas en la nieve (Stepping Snow) — Paquete Naturaleza

  RESPIRACIÓN GUIADA HÁPTICA
  Cierra los ojos y sigue el ritmo con el dedo sobre la pantalla. El motor háptico modula la intensidad de forma progresiva en cada fase de cuatro técnicas científicamente calibradas:
  • Calma 4-2-6-2 para activar el sistema parasimpático
  • Respiración cuadrada 4-4-4-4 (Box Breathing) para concentración
  • Técnica 4-7-8 para relajación profunda y descanso
  • Coherencia resonante 5-0-5-0 para equilibrio HRV

  PAISAJES SONOROS Y PERSONALIZACIÓN
  • 5 paisajes sonoros continuos en estéreo (Jardín Zen, Resonancia Cósmica, Cuencos Tibetanos, Arroyo del Bosque y Lluvia Nocturna).
  • Ajuste fino de intensidad háptica, nitidez, volumen, sensibilidad tonal y estilo visual (Ondas, Partículas o Sombra).
  • Objetivo diario personalizable (de 5 a 60 minutos) sincronizado con los widgets de pantalla de inicio y bloqueo.
  • Integración opcional con Apple Health (Mindful Minutes).

  PRIVACIDAD ABSOLUTA
  Sin cuentas, sin anuncios y sin rastreadores. Tus preferencias y tu progreso diario permanecen exclusivamente en tu dispositivo.
  ```

---

### 🔵 Anglès (`en-US`)

* **Subtítol** *(màx. 30 caràcters)*:
  `Tactile Mindfulness & ASMR` *(26 caràcters)*

* **Text promocional** *(màx. 170 caràcters)*:
  `Turn your iPhone into a tactile sanctuary. Feel lifelike textures via Core Haptics, practice haptic-guided breathing, and sync Mindful Minutes with Apple Health.` *(158 caràcters)*

* **Paraules clau** *(màx. 100 caràcters)*:
  `haptic,asmr,mindfulness,relaxation,calm,breathing,tactile,stress,anxiety,meditation,zen,sleep,focus` *(99 caràcters)*

* **Descripció**:
  ```text
  Haptic Zen turns your iPhone into a calming sensory sanctuary crafted to ease stress, soothe anxiety, and restore focus through precision touch and spatial sound.

  ENGINEERED FOR THE TAPTIC ENGINE
  Glide your finger across a distraction-free dark canvas and feel dynamic Core Haptics paired with velocity-reactive spatial ASMR audio:
  • Bubble Wrap — included free
  • Kinetic Sand — included free
  • Typewriter — Mechanical Pack
  • Gears — Mechanical Pack
  • Heavy Rain — Nature Pack
  • Stepping Snow — Nature Pack

  HAPTIC-GUIDED BREATHING
  Close your eyes and rest a finger on the breathing sphere. Continuous haptic modulation guides every inhale, hold, and exhale across four calibrated techniques:
  • Paced 4-2-6-2 for parasympathetic calming
  • Box Breathing 4-4-4-4 for focus and emotional balance
  • 4-7-8 Relaxation for deep calm and sleep readiness
  • Resonant 5-0-5-0 for Heart Rate Variability coherence

  AMBIENT SOUNDSCAPES & PERSONALIZATION
  • 5 seamless stereo soundscapes (Zen Garden, Cosmic Resonance, Tibetan Bowls, Forest Stream, and Night Rain).
  • Fine-tune haptic intensity, sharpness, audio volume, pitch response, and visual style (Ripple, Particles, or Shadow).
  • Customizable daily mindful goal (5–60 minutes) synced live to Home Screen and Lock Screen widgets.
  • Optional Apple Health integration to save Mindful Minutes.

  PRIVATE BY DESIGN
  No accounts, no ads, no analytics SDKs. All preferences and daily mindfulness stats stay strictly on your device.
  ```

---

## 3. Productes In-App Purchase (StoreKit 2)

Configurar a **App Store Connect → Monetization → In-App Purchases** amb els mateixos identificadors de `ProductIDs.swift` i `HapticZen.storekit`:

| Product ID | Tipus | Family Sharing | Preu orientatiu | Nom (`ca` / `es` / `en`) |
| :--- | :--- | :---: | :---: | :--- |
| `com.hapticzen.pack.mechanical` | Non-Consumable | Sí | $1.99 | Paquet Mecànic / Paquete Mecánico / Mechanical Pack |
| `com.hapticzen.pack.nature` | Non-Consumable | Sí | $1.99 | Paquet Natural / Paquete Naturaleza / Nature Pack |

Descripcions per a revisió:
* **`com.hapticzen.pack.mechanical`**:
  * `ca`: *Sensacions mecàniques de precisió i clics tàctils satisfactoris (Màquina d'escriure i Engranatges).*
  * `es`: *Sensaciones mecánicas de precisión y clics táctiles satisfactorios (Máquina de escribir y Engranajes).*
  * `en`: *Precision mechanical clicks and satisfying tactile feedback (Typewriter and Gears).*
* **`com.hapticzen.pack.nature`**:
  * `ca`: *Experiències orgàniques i naturals immersives amb sons ASMR (Pluja intensa i Petjades a la neu).*
  * `es`: *Experiencias orgánicas y naturales inmersivas con sonidos ASMR (Lluvia intensa y Pisadas en la nieve).*
  * `en`: *Immersive organic and natural experiences with ASMR soundscapes (Heavy Rain and Stepping Snow).*

---

## 4. Etiqueta de Privadesa (*App Privacy*)

Coherent amb `HapticZen/Resources/PrivacyInfo.xcprivacy` i `HapticZenWidgets/PrivacyInfo.xcprivacy`:

* **Data Not Collected**: Seleccionar **"No, we do not collect data from this app."**
  * L'app no envia cap dada fora del dispositiu, no fa servir analítica ni SDKs de tercers, i les dades de HealthKit només s'escriuen localment a l'app Salut d'Apple sota permís explícit de l'usuari (`NSHealthUpdateUsageDescription`).
* **URL de Política de Privadesa**: Publica [`docs/privacy.html`](privacy.html) (per exemple via GitHub Pages) i enganxa la URL resultant a App Store Connect.

---

## 5. Notes per als Revisors d'Apple (*App Review Notes*)

```text
Thank you for reviewing Haptic Zen!

1. Navigation / Accessing the Menu:
   The main screen is a distraction-free tactile canvas. After dismissing the initial onboarding screen, open the menu using any of these gestures:
   - Tap anywhere with 3 fingers, OR
   - Swipe left from the right edge of the screen, OR
   - Use VoiceOver Magic Tap.

2. Hardware Note (Core Haptics):
   Haptic Zen relies on Apple's Core Haptics / Taptic Engine for tactile textures and guided breathing feedback. Please test on a physical iPhone (iOS Simulator does not produce haptic feedback).

3. HealthKit Integration:
   HealthKit tracking is disabled by default and is strictly opt-in under Menu -> Settings -> Sync with Apple Health. When enabled, sessions longer than 5 seconds are saved locally as Mindful Minutes.

4. In-App Purchases:
   Two Non-Consumable texture packs (com.hapticzen.pack.mechanical and com.hapticzen.pack.nature) and a Restore Purchases button are accessible under Menu -> Store (or by tapping any locked texture).
```
