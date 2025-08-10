# 🌿 QBX-TABAC

QBX-TABAC est un script métier complet pour **QBX Core** permettant de récolter, transformer et vendre du tabac de manière immersive sur votre serveur FiveM.

Ce script utilise **ox_target** et **ox_lib** pour les interactions, et gère le spawn/despawn dynamique de plantes de tabac sur la carte.

---

## 📌 Fonctionnalités

- 🌱 **Récolte dynamique** : Spawn aléatoire de plantes dans des champs prédéfinis  
- 🔄 **Respawn automatique** des plantes après collecte complète  
- 🏭 **Transformation** du tabac récolté en cigarettes  
- 💰 **Vente** des cigarettes auprès d’un PNJ ou zone dédiée  
- 🔒 Anti-spam récolte grâce à un flag `isHarvesting`  
- 🎯 Utilisation d’**ox_target** pour toutes les interactions  
- 📍 Zones de **process** et **vente** configurables  

---

## 📂 Dépendances

Assurez-vous d’avoir installé :

- [qbx_core](https://github.com/Qbox-project/qbx_core)
- [ox_target](https://github.com/overextended/ox_target)
- [ox_lib](https://github.com/overextended/ox_lib)

---

## ⚙️ Installation

1. Téléchargez le script et placez-le dans votre dossier `resources/[qbx]`
2. Ajoutez dans votre `server.cfg` :
    ```cfg
    ensure ox_lib
    ensure ox_target
    ensure qbx_core
    ensure QBX-TABAC
    ```
3. Ajoutez les **items** ci-dessous dans votre base de données (table `items`)

---

## 📦 Items requis

| nom           | label         | poids | description                   |
|---------------|--------------|-------|--------------------------------|
| tabac         | Feuille de tabac | 100   | Tabac brut récolté dans les champs |
| cigarette     | Cigarette     | 50    | Cigarette roulée prête à vendre |


À ajouter dans votre `ox_inventory/shared/items.lua` ou équivalent :

```lua
['tabac_brut'] = {
    label = 'Tabac Brut',
    description = "Des feuilles pour créer des cigarettes",
    weight = 50,
    client = {
        image = "tabac_brut.png",
    },
},

['cigarette'] = { -- social item that causes slight damage to health
    label = 'Cigarettes',
    weight = 115,
    description = "These probably aren't good for you, but fuck it",
    client = {
        anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c', flag = 49 },
        prop = { model = 'bzzz_cigarpack_cig002', 
        pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422 },
        disable = { move = false, car = false, combat = true },
        usetime = 16000,
    }
},
```
---

## 🛠️ Configuration

Le fichier `Config.lua` contient :

```lua
Config = {}

-- Modèle de la plante
Config.PlantModel = `prop_plant_01`

-- Coordonnées des champs (ID unique => coords)
Config.Fields = {
    [1] = vector3(123.4, 456.7, 78.9),
    [2] = vector3(125.4, 458.7, 78.9),
    -- Ajoutez autant de points que vous voulez
}

-- Coordonnées de la zone de transformation
Config.Process = vector3(200.0, -1000.0, 30.0)

-- Coordonnées de la zone de vente
Config.Sell = vector3(210.0, -1010.0, 30.0)
