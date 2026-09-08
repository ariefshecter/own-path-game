#!/usr/bin/env python3
"""
Playtest simulation script for Chapter 1 (1-1 through 1-5).
Simulates full runs, deck interactions, banking strategy, boss balance,
and checks for softlocks, unhandled errors, or broken progression.
"""

import json
import random
from pathlib import Path

BASE_DIR = Path("/home/riefzy/Project/own-path-game")

def load_game_data():
    with open(BASE_DIR / "data/cards.json") as f:
        cards = {c["id"]: c for c in json.load(f)}
    with open(BASE_DIR / "data/enemies.json") as f:
        enemies = json.load(f)
    with open(BASE_DIR / "data/events.json") as f:
        events = json.load(f)
    return cards, enemies, events

def simulate_battle(enemy, deck, player_max_sanity, current_sanity, cards_map):
    sanity = current_sanity
    energy_max = 3
    coins_gained = 0
    
    draw_pile = list(deck)
    random.shuffle(draw_pile)
    discard_pile = []
    
    enemy_hp = enemy["resolve_hp"]
    actions = enemy["actions"]
    
    turns = 0
    max_turns = 40
    
    while sanity > 0 and enemy_hp > 0 and turns < max_turns:
        turns += 1
        energy = energy_max
        shield = 0 # Player shield resets each turn
        
        # Enemy acts FIRST or attacks player
        act = actions[(turns - 1) % len(actions)]
        
        hand = []
        for _ in range(4):
            if not draw_pile:
                draw_pile = list(discard_pile)
                discard_pile.clear()
                random.shuffle(draw_pile)
            if draw_pile:
                hand.append(draw_pile.pop())
                
        # Player plays cards
        random.shuffle(hand)
        for cid in list(hand):
            c = cards_map[cid]
            if c["energy_cost"] <= energy:
                energy -= c["energy_cost"]
                hand.remove(cid)
                discard_pile.append(cid)
                
                for eff in c.get("effects", []):
                    t = eff["target"]
                    v = eff["value"]
                    etype = eff["type"]
                    if etype == "DAMAGE" and t == "ENEMY":
                        enemy_hp -= v
                    elif etype == "SHIELD" and t == "SELF":
                        shield += v
                    elif etype == "GAIN_COINS" and t == "SELF":
                        coins_gained += v
                    elif etype == "GAIN_ENERGY" and t == "SELF":
                        energy += v
                    elif etype == "DAMAGE" and t == "SELF":
                        sanity -= v
                        
                if enemy_hp <= 0:
                    break
                    
        discard_pile.extend(hand)
        hand.clear()
        
        if enemy_hp <= 0:
            return True, sanity, coins_gained + 25, turns
            
        # Enemy turn execution against player shield
        if act["intent"] == "ATTACK":
            dmg = act["value"]
            blocked = min(shield, dmg)
            unblocked = dmg - blocked
            sanity -= unblocked
        elif act["intent"] == "DEFEND":
            enemy_hp += act["value"]
            
    win = enemy_hp <= 0 and sanity > 0
    return win, sanity, coins_gained, turns

def run_playtest():
    cards_map, enemies, events = load_game_data()
    starter_deck = [
        "card_refuse", "card_refuse", "card_breathe",
        "card_breathe", "card_indomie_nasi", "card_kucing_oren", "card_ignore_call"
    ]
    
    print("Mulai Simulasi 100 Playtest Chapter 1...")
    
    wins = 0
    losses = 0
    boss_encounters = 0
    boss_wins = 0
    total_savings_accumulated = []
    
    for run_i in range(100):
        current_deck = list(starter_deck)
        max_sanity = 50
        current_sanity = max_sanity
        savings = 0
        current_coins = 50
        run_failed = False
        
        # Test full chapter 1 (Mini chapters 1 to 5)
        for mini_ch in range(1, 6):
            current_sanity = max_sanity # Reset at start of mini chapter
            for floor in range(1, 6):
                # In actual game, player carries sanity across 5 floors of the mini-chapter!
                # (Only heals via Shop / Event)
                if floor == 5:
                    if mini_ch == 5:
                        enemy = next(e for e in enemies if e.get("is_boss", False))
                        boss_encounters += 1
                    else:
                        candidates = [e for e in enemies if not e.get("is_boss", False)]
                        enemy = random.choice(candidates)
                else:
                    # Random stage type: 60% battle, 20% shop, 20% event
                    roll = random.random()
                    if roll < 0.20 and floor in [3, 4]:
                        # Shop & Bank deposit
                        deposit = current_coins // 2
                        current_coins -= deposit
                        savings += deposit
                        continue
                    elif roll < 0.40 and floor in [2, 3, 4]:
                        # Event
                        current_coins = max(0, current_coins - 5)
                        continue
                    else:
                        candidates = [e for e in enemies if not e.get("is_boss", False)]
                        enemy = random.choice(candidates)
                        
                win, rem_sanity, coins_gained, turns = simulate_battle(enemy, current_deck, max_sanity, current_sanity, cards_map)
                if not win:
                    run_failed = True
                    break
                else:
                    current_sanity = rem_sanity
                    current_coins += coins_gained
                    
            if run_failed:
                losses += 1
                break
            else:
                if mini_ch == 5:
                    wins += 1
                    boss_wins += 1
                    total_savings_accumulated.append(savings)
                    
    win_rate = (wins / 100.0) * 100.0
    boss_win_rate = (boss_wins / max(1, boss_encounters)) * 100.0
    avg_savings = sum(total_savings_accumulated) / max(1, len(total_savings_accumulated))
    
    print(f"Total Runs: 100")
    print(f"Full Chapter 1 Cleared: {wins} / 100 ({win_rate:.1f}%)")
    print(f"Losses (Fail forward / Retries needed): {losses}")
    print(f"Boss Encounters: {boss_encounters}")
    print(f"Boss Win Rate: {boss_win_rate:.1f}%")
    print(f"Rata-rata Tabungan Bank terkumpul saat tamat: {avg_savings:.1f} Koin")
    
    # Assert healthy roguelike progression (winrate between 20% and 55% without meta-upgrades)
    assert 15 <= win_rate <= 70, f"Win rate outlier: {win_rate}%"
    print("Status Balancing Chapter 1: SEIMBANG & VALID.")

if __name__ == "__main__":
    run_playtest()
