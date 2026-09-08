#!/usr/bin/env python3
"""
Prototype CLI Turn-Based Battle Loop untuk validasi angka & mechanics 'Jalan Sendiri'.
Menguji formula kartu, perisai, status mental pemain, dan aksi musuh.
"""

import json
import random
from pathlib import Path

DATA_DIR = Path(__file__).parent / "data"

def load_data():
    with open(DATA_DIR / "cards.json", "r") as f:
        cards = json.load(f)
    with open(DATA_DIR / "enemies.json", "r") as f:
        enemies = json.load(f)
    return {c["id"]: c for c in cards}, enemies

def run_prototype():
    cards_map, enemies = load_data()
    enemy = enemies[0] # Rasa Bersalah
    
    # Player state
    sanity = 50
    max_sanity = 50
    energy = 3
    max_energy = 3
    shield = 0
    coins = 0
    
    deck = ["card_refuse", "card_refuse", "card_breathe", "card_breathe", "card_overtime", "card_coffee", "card_ignore_call"]
    draw_pile = list(deck)
    random.shuffle(draw_pile)
    discard_pile = []
    
    enemy_hp = enemy["resolve_hp"]
    enemy_turn_idx = 0
    
    print("=" * 60)
    print(f"BATTLE START: Menghadapi [{enemy['name']}] (HP: {enemy_hp})")
    print("=" * 60)
    
    turn = 1
    while sanity > 0 and enemy_hp > 0:
        print(f"\n--- GILIRAN {turn} ---")
        energy = max_energy
        shield = 0 # Shield reset tiap awal giliran pemain
        
        # Draw 4 kartu
        hand = []
        for _ in range(4):
            if not draw_pile:
                draw_pile = list(discard_pile)
                discard_pile.clear()
                random.shuffle(draw_pile)
            if draw_pile:
                hand.append(draw_pile.pop())
                
        # Tampilkan niat musuh
        current_enemy_action = enemy["actions"][enemy_turn_idx % len(enemy["actions"])]
        print(f"Musuh: [{enemy['name']}] | HP: {enemy_hp}")
        print(f"Niat Musuh: {current_enemy_action['intent']} ({current_enemy_action['value']}) -> {current_enemy_action['dialogue']}")
        print(f"Status Pemain: Mental {sanity}/{max_sanity} | Perisai: {shield} | Energi: {energy}/{max_energy} | Koin Run: {coins}")
        
        # Player action loop
        while True:
            print("\nKartu di Tangan:")
            for i, card_id in enumerate(hand):
                c = cards_map[card_id]
                print(f" [{i+1}] {c['name']} (Biaya: {c['energy_cost']}) -> {c['flavor']}")
            print(" [0] Akhiri Giliran")
            
            # Autoplay bot logic atau pilihan kartu jika ada energi
            playable = [i for i, cid in enumerate(hand) if cards_map[cid]["energy_cost"] <= energy]
            if not playable or energy == 0:
                print(">> Tidak ada energi tersisa atau memilih akhiri giliran.")
                break
                
            # Mainkan kartu pertama yang bisa dimainkan (simulasi loop auto)
            pick_idx = playable[0]
            card_id = hand.pop(pick_idx)
            card = cards_map[card_id]
            energy -= card["energy_cost"]
            discard_pile.append(card_id)
            
            print(f">> Memainkan [{card['name']}]!")
            for eff in card["effects"]:
                target = eff["target"]
                val = eff["value"]
                etype = eff["type"]
                if etype == "DAMAGE" and target == "ENEMY":
                    enemy_hp -= val
                    print(f"   Memberikan {val} tekanan pada {enemy['name']}. Sisa HP Musuh: {max(0, enemy_hp)}")
                elif etype == "SHIELD" and target == "SELF":
                    shield += val
                    print(f"   Mendapatkan {val} Perisai Mental. Total Shield: {shield}")
                elif etype == "GAIN_COINS" and target == "SELF":
                    coins += val
                    print(f"   Mendapatkan {val} Koin Run. Total: {coins}")
                elif etype == "GAIN_ENERGY" and target == "SELF":
                    energy += val
                    print(f"   Energi bertambah {val}. Energi sekarang: {energy}")
                elif etype == "DAMAGE" and target == "SELF":
                    sanity -= val
                    print(f"   Menderita {val} kerusakan mental! Mental sisa: {sanity}")
                    
            if enemy_hp <= 0:
                break
                
        # Sisa kartu tangan dibuang ke discard pile
        discard_pile.extend(hand)
        hand.clear()
        
        if enemy_hp <= 0:
            print("\n" + "=" * 60)
            print(f"KEMENANGAN! Kamu berhasil mengatasi [{enemy['name']}].")
            print(f"Reward Run: +25 Koin (Total Koin Run: {coins + 25})")
            print("=" * 60)
            return True
            
        # Musuh bertindak
        print(f"\n>> Giliran Musuh: [{enemy['name']}] bertindak!")
        if current_enemy_action["intent"] == "ATTACK":
            dmg = current_enemy_action["value"]
            blocked = min(shield, dmg)
            unblocked = dmg - blocked
            shield -= blocked
            sanity -= unblocked
            print(f"   {enemy['name']} menyerang sebesar {dmg}!")
            if blocked > 0:
                print(f"   Perisai menahan {blocked} damage.")
            if unblocked > 0:
                print(f"   Mentalmu berkurang {unblocked}. Sisa Mental: {sanity}")
        elif current_enemy_action["intent"] == "DEFEND":
            enemy_hp += current_enemy_action["value"]
            print(f"   {enemy['name']} memperkuat pertahanan psikologisnya (+{current_enemy_action['value']} HP)!")
            
        enemy_turn_idx += 1
        turn += 1
        
        if sanity <= 0:
            print("\n" + "=" * 60)
            print("KEKALAHAN: Mentalmu runtuh sebelum mencapai lantai berikutnya.")
            print("Kamu terpaksa mengulang mini chapter ini.")
            print("=" * 60)
            return False

if __name__ == "__main__":
    run_prototype()
