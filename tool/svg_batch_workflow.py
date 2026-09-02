#!/usr/bin/env python3
"""
SVG Batch Workflow System for Deutsch Garden

This system helps create SVG visuals in batches by providing:
1. Word batch management
2. Specific instructions for each word
3. Progress tracking
4. Quality verification

Usage:
    python svg_batch_workflow.py --new-batch 10    # Start new batch of 10 words
    python svg_batch_workflow.py --list-batch       # Show current batch
    python svg_batch_workflow.py --instructions     # Show instructions for current batch
    python svg_batch_workflow.py --complete        # Mark batch as complete
    python svg_batch_workflow.py --status          # Show overall progress
"""

import os
import json
import re
import argparse
from pathlib import Path
from datetime import datetime

# Project directories
PROJECT_ROOT = Path(r"C:\Personal Projects\deutsch-garden")
ASSETS_DIR = PROJECT_ROOT / "assets" / "vocab"
LIB_DIR = PROJECT_ROOT / "lib"
TOOL_DIR = PROJECT_ROOT / "tool"

# Vocabulary source files
VOCAB_FILES = {
    "core": LIB_DIR / "vocabulary.dart",
    "expansion": LIB_DIR / "vocabulary_expansion.dart",
    "extra": LIB_DIR / "vocabulary_extra.dart",
    "generated": LIB_DIR / "vocabulary_generated.dart"
}

# Batch files
BATCH_DIR = TOOL_DIR / "batches"
CURRENT_BATCH_FILE = TOOL_DIR / "current_batch.json"
COMPLETED_BATCHES_FILE = TOOL_DIR / "completed_batches.json"

# Color palette (from existing SVGs)
COLORS = {
    "skin": "#E8B08A",      # Used for people, faces
    "blue": "#378ADD",      # Used for clothes, water
    "red": "#E24B4A",       # Used for clothing, cars, important
    "brown": "#8A5A2B",     # Used for wood, hair, handles
    "beige": "#FAC775",     # Used for buildings, paper, light
    "gray": "#888780",      # Used for buildings, objects
    "light_blue": "#85B7EB", # Used for windows, eyes
    "orange": "#EF9F27",     # Used for accents, highlights
    "green": "#639922",     # Used for plants, positive
    "dark": "#444441",      # Used for shadows, details
}

# Predefined visual instructions for common words
VISUAL_INSTRUCTIONS = {
    # Language category
    "wort": {
        "concept": "Open book showing pages",
        "shapes": ["rect (left cover)", "rect (right cover)", "rect (left page)", "rect (right page)", "path (spine)", "path (text lines)"],
        "colors": {"cover": "brown", "pages": "beige", "lines": "dark"},
        "svg": '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect x="18" y="20" width="12" height="20" rx="1" fill="#8A5A2B"/>
  <rect x="34" y="20" width="12" height="20" rx="1" fill="#8A5A2B"/>
  <rect x="20" y="22" width="8" height="16" fill="#FAC775"/>
  <rect x="36" y="22" width="8" height="16" fill="#FAC775"/>
  <path d="M20 25 L36 25" stroke="#444441" stroke-width="0.5"/>
  <path d="M20 28 L36 28" stroke="#444441" stroke-width="0.5"/>
  <path d="M20 31 L36 31" stroke="#444441" stroke-width="0.5"/>
  <path d="M20 34 L36 34" stroke="#444441" stroke-width="0.5"/>
  <rect x="30" y="20" width="4" height="20" fill="#8A5A2B"/>
</svg>'''
    },
    "satz": {
        "concept": "Three connected speech bubbles",
        "shapes": ["path (bubble 1)", "path (bubble 2)", "path (bubble 3)"],
        "colors": {"bubbles": "light_blue"},
        "svg": '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <path d="M12 20 Q12 12 17 12 Q22 12 25 15 Q25 20 17 20 Z" fill="#85B7EB"/>
  <path d="M28 25 Q28 17 33 17 Q38 17 41 20 Q41 25 33 25 Z" fill="#85B7EB"/>
  <path d="M44 30 Q44 22 49 22 Q54 22 57 25 Q57 30 49 30 Z" fill="#85B7EB"/>
  <path d="M25 18 L28 22" stroke="#85B7EB" stroke-width="1" fill="none"/>
  <path d="M41 22 L44 27" stroke="#85B7EB" stroke-width="1" fill="none"/>
</svg>'''
    },
    "grammatik": {
        "concept": "Stack of grammar books",
        "shapes": ["rect (book 1)", "rect (book 2)", "rect (book 3)", "path (lines)"],
        "colors": {"covers": "red", "pages": "beige", "lines": "dark"},
        "svg": '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect x="20" y="25" width="24" height="4" fill="#E24B4A" rx="1"/>
  <rect x="20" y="30" width="24" height="4" fill="#E24B4A" rx="1"/>
  <rect x="20" y="35" width="24" height="4" fill="#E24B4A" rx="1"/>
  <rect x="22" y="27" width="20" height="2" fill="#FAC775"/>
  <rect x="22" y="32" width="20" height="2" fill="#FAC775"/>
  <path d="M22 29 L42 29" stroke="#444441" stroke-width="0.5"/>
  <path d="M22 34 L42 34" stroke="#444441" stroke-width="0.5"/>
</svg>'''
    },
    "bedeutung": {
        "concept": "Lightbulb with rays",
        "shapes": ["path (bulb outline)", "path (filament)", "rect (base)", "path (rays)"],
        "colors": {"bulb": "orange", "base": "dark"},
        "svg": '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <path d="M28 25 Q25 15 30 12 Q35 15 32 25" fill="#EF9F27"/>
  <path d="M28 25 L32 35" stroke="#EF9F27" stroke-width="2"/>
  <path d="M32 25 L36 35" stroke="#EF9F27" stroke-width="2"/>
  <path d="M28 35 L36 35" stroke="#EF9F27" stroke-width="2"/>
  <circle cx="32" cy="40" r="4" fill="#EF9F27"/>
  <rect x="30" y="44" width="4" height="4" fill="#444441"/>
  <path d="M32 48 L32 52" stroke="#444441" stroke-width="2"/>
  <path d="M28 50 L36 50" stroke="#444441" stroke-width="1"/>
</svg>'''
    },
    "aussprache": {
        "concept": "Mouth with sound waves",
        "shapes": ["ellipse (mouth)", "path (tongue)", "path (waves)"],
        "colors": {"mouth": "skin", "waves": "blue"},
        "svg": '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <ellipse cx="32" cy="35" rx="8" ry="6" fill="#E8B08A"/>
  <path d="M28 35 Q32 40 36 35" stroke="#444441" stroke-width="2" fill="none"/>
  <path d="M40 25 Q44 20 48 25" stroke="#378ADD" stroke-width="1" fill="none"/>
  <path d="M48 25 Q52 20 56 25" stroke="#378ADD" stroke-width="1" fill="none"/>
  <path d="M56 25 Q60 20 64 25" stroke="#378ADD" stroke-width="1" fill="none"/>
</svg>'''
    },
    "fehler": {
        "concept": "Circle with X mark (error symbol)",
        "shapes": ["circle", "path (X)"],
        "colors": {"all": "red"},
        "svg": '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <circle cx="32" cy="32" r="16" fill="#E24B4A"/>
  <path d="M22 22 L42 42" stroke="#E24B4A" stroke-width="4" stroke-linecap="round"/>
  <path d="M42 22 L22 42" stroke="#E24B4A" stroke-width="4" stroke-linecap="round"/>
</svg>'''
    },
    "übung": {
        "concept": "Checkmark in a box",
        "shapes": ["rect (box)", "path (checkmark)"],
        "colors": {"checkmark": "green", "box": "beige"},
        "svg": '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect x="22" y="25" width="20" height="20" rx="2" fill="#FAC775" stroke="#444441" stroke-width="1"/>
  <path d="M28 35 L34 42 L40 30" stroke="#639922" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
</svg>'''
    },
    "geld": {
        "concept": "Coin with euro symbol",
        "shapes": ["circle (outer)", "circle (inner)", "path (euro symbol)"],
        "colors": {"outer": "orange", "inner": "beige", "symbol": "brown"},
        "svg": '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <circle cx="32" cy="32" r="14" fill="#EF9F27"/>
  <circle cx="32" cy="32" r="10" fill="#FAC775"/>
  <path d="M32 20 L32 44" stroke="#8A5A2B" stroke-width="2"/>
  <path d="M20 32 L44 32" stroke="#8A5A2B" stroke-width="2"/>
</svg>'''
    },
    "preis": {
        "concept": "Price tag",
        "shapes": ["rect (tag)", "path (hole)"],
        "colors": {"tag": "beige", "hole": "dark"},
        "svg": '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <path d="M25 20 L45 20 L45 35 L30 35 L25 40 Z" fill="#FAC775" stroke="#444441" stroke-width="1"/>
  <circle cx="40" cy="15" r="2" fill="#444441"/>
  <path d="M38 15 L42 15" stroke="#444441" stroke-width="1"/>
</svg>'''
    },
    "geschäft": {
        "concept": "Store front with awning",
        "shapes": ["rect (building)", "path (awning)", "rect (door)", "rect (windows)"],
        "colors": {"building": "gray", "awning": "red", "door": "brown", "windows": "beige"},
        "svg": '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect x="20" y="30" width="24" height="20" fill="#888780"/>
  <path d="M18 30 L32 20 L46 30" fill="#E24B4A"/>
  <rect x="28" y="40" width="8" height="10" fill="#8A5A2B"/>
  <rect x="24" y="33" width="4" height="4" fill="#FAC775"/>
  <rect x="36" y="33" width="4" height="4" fill="#FAC775"/>
</svg>'''
    },
}

def ensure_dirs():
    """Ensure all required directories exist."""
    TOOL_DIR.mkdir(exist_ok=True)
    BATCH_DIR.mkdir(exist_ok=True)
    ASSETS_DIR.mkdir(exist_ok=True)


def get_svg_files():
    """Get list of existing SVG files."""
    svg_files = []
    if ASSETS_DIR.exists():
        for svg_file in ASSETS_DIR.glob("*.svg"):
            svg_files.append(svg_file.stem)
    return sorted(svg_files)


def parse_vocabulary_file(file_path):
    """Parse a Dart vocabulary file and extract word info."""
    word_list = []

    if not file_path.exists():
        return word_list

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract GermanWord blocks
    pattern = r'GermanWord\([^)]*id:\s*\'([^\']+)\'[^)]*article:\s*\'([^\']*)\'[^)]*german:\s*\'([^\']*)\'[^)]*english:\s*\'([^\']*)\'[^)]*category:\s*\'([^\']*)\'[^)]*level:\s*\'([^\']*)\'[^)]*\)'
    matches = re.findall(pattern, content, re.DOTALL)

    for match in matches:
        word_id, article, german, english, category, level = match
        word_list.append({
            "id": word_id,
            "article": article,
            "german": german,
            "english": english,
            "category": category,
            "level": level,
            "source": file_path.stem
        })

    return word_list


def get_all_words():
    """Get all words from all vocabulary files."""
    all_words = []

    for vocab_type, file_path in VOCAB_FILES.items():
        words = parse_vocabulary_file(file_path)
        all_words.extend(words)

    return all_words


def find_missing_words():
    """Find which words are missing SVG files."""
    all_words = get_all_words()
    existing_svgs = get_svg_files()
    svg_set = set(existing_svgs)

    missing_words = [word for word in all_words if word["id"] not in svg_set]
    return sorted(missing_words, key=lambda w: w["id"])


def create_new_batch(batch_size=10):
    """Create a new batch of words to work on."""
    ensure_dirs()

    missing_words = find_missing_words()

    if not missing_words:
        print("All words already have SVGs!")
        return None

    # Take the first batch_size words
    batch_words = missing_words[:batch_size]

    batch_data = {
        "batch_id": len(list(BATCH_DIR.glob("batch_*.json"))) + 1,
        "created": datetime.now().isoformat(),
        "words": batch_words,
        "status": "in_progress",
        "completion": 0
    }

    # Save batch file
    batch_file = BATCH_DIR / f"batch_{batch_data['batch_id']}.json"
    with open(batch_file, 'w', encoding='utf-8') as f:
        json.dump(batch_data, f, indent=2, ensure_ascii=False)

    # Save as current batch
    with open(CURRENT_BATCH_FILE, 'w', encoding='utf-8') as f:
        json.dump(batch_data, f, indent=2, ensure_ascii=False)

    print(f"Created new batch {batch_data['batch_id']} with {len(batch_words)} words")
    return batch_data


def load_current_batch():
    """Load the current batch."""
    if CURRENT_BATCH_FILE.exists():
        with open(CURRENT_BATCH_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return None


def list_current_batch():
    """List words in the current batch."""
    batch = load_current_batch()

    if not batch:
        print("No current batch. Create one with --new-batch")
        return

    print(f"\nCurrent Batch {batch['batch_id']} ({batch['status']})")
    print("=" * 50)

    for i, word in enumerate(batch['words'], 1):
        svg_file = ASSETS_DIR / f"{word['id']}.svg"
        status = "✓" if svg_file.exists() else " "
        print(f"{status} {i:2d}. {word['id']:>5s} - {word['german']:<15s} ({word['english']})")

    print("=" * 50)
    print(f"Total: {len(batch['words'])} words")

    # Count completed
    completed = sum(1 for word in batch['words'] if (ASSETS_DIR / f"{word['id']}.svg").exists())
    print(f"Completed: {completed}/{len(batch['words'])} ({completed/len(batch['words'])*100:.1f}%)")


def show_instructions():
    """Show specific instructions for each word in the current batch."""
    batch = load_current_batch()

    if not batch:
        print("No current batch. Create one with --new-batch")
        return

    print(f"\nInstructions for Batch {batch['batch_id']}")
    print("=" * 60)

    for word in batch['words']:
        svg_file = ASSETS_DIR / f"{word['id']}.svg"

        # Check if SVG already exists
        if svg_file.exists():
            print(f"\n✓ {word['id']}: {word['german']} ({word['english']})")
            print("  Status: Already has SVG")
            continue

        # Get predefined instructions or create generic
        word_key = word['german'].lower()
        instructions = VISUAL_INSTRUCTIONS.get(word_key)

        print(f"\n  {word['id']}: {word['german']} ({word['english']})")
        print(f"  Category: {word['category']}")
        print(f"  Level: {word['level']}")

        if instructions:
            print(f"  Visual: {instructions['concept']}")
            print(f"  Shapes: {', '.join(instructions['shapes'])}")
            print(f"  Colors: {instructions['colors']}")
            print(f"  SVG: (predefined available)")
        else:
            # Generate generic instructions based on category
            category_instructions = get_category_instructions(word['category'], word['german'])
            print(f"  Visual: {category_instructions['concept']}")
            print(f"  Shapes: {', '.join(category_instructions['shapes'])}")
            print(f"  Colors: {category_instructions['colors']}")
            print(f"  Notes: {category_instructions['notes']}")

    print("\n" + "=" * 60)


def get_category_instructions(category, german_word):
    """Get generic instructions based on category."""
    word_lower = german_word.lower()

    # People category
    if category == "People":
        return {
            "concept": "Person silhouette",
            "shapes": ["circle (head)", "rect (body)", "path (legs)"],
            "colors": {"head": "skin", "body": "blue or red", "details": "dark"},
            "notes": "Create different poses based on the specific word"
        }

    # Food category
    elif category == "Food":
        return {
            "concept": f"{german_word} shape",
            "shapes": ["circle", "path", "rect"],
            "colors": {"main": "orange or red", "details": "green or brown"},
            "notes": f"Create a recognizable shape for {german_word}"
        }

    # Transport category
    elif category == "Transport":
        return {
            "concept": f"{german_word} vehicle",
            "shapes": ["rect (body)", "circle (wheels)", "path (details)"],
            "colors": {"body": "blue or gray", "wheels": "dark", "details": "brown"},
            "notes": f"Create a simple vehicle shape for {german_word}"
        }

    # Home category
    elif category == "Home":
        return {
            "concept": f"{german_word} furniture/object",
            "shapes": ["rect", "path"],
            "colors": {"main": "beige or brown", "details": "dark"},
            "notes": f"Create a household object for {german_word}"
        }

    # Nature category
    elif category == "Nature":
        return {
            "concept": f"{german_word} natural element",
            "shapes": ["circle", "path", "rect"],
            "colors": {"main": "green or blue", "details": "brown or orange"},
            "notes": f"Create a nature element for {german_word}"
        }

    # Default for all other categories
    else:
        return {
            "concept": f"Symbolic representation of {german_word}",
            "shapes": ["circle", "rect", "path"],
            "colors": {"main": "blue", "details": "dark"},
            "notes": f"Create a unique visual metaphor for {german_word}. Study existing SVGs for inspiration."
        }


def save_svg_from_instructions(word_id, svg_content):
    """Save SVG content to file."""
    ensure_dirs()
    svg_path = ASSETS_DIR / f"{word_id}.svg"

    with open(svg_path, 'w', encoding='utf-8') as f:
        f.write(svg_content)

    return svg_path


def use_predefined_svg(word_id):
    """Use a predefined SVG for a word."""
    batch = load_current_batch()
    if not batch:
        return False

    for word in batch['words']:
        if word['id'] == word_id:
            word_key = word['german'].lower()
            if word_key in VISUAL_INSTRUCTIONS:
                instructions = VISUAL_INSTRUCTIONS[word_key]
                save_svg_from_instructions(word_id, instructions['svg'])
                print(f"Saved predefined SVG for {word['german']} ({word_id})")
                return True

    return False


def use_all_predefined():
    """Use all predefined SVGs in the current batch."""
    batch = load_current_batch()
    if not batch:
        print("No current batch")
        return 0

    count = 0
    for word in batch['words']:
        word_key = word['german'].lower()
        if word_key in VISUAL_INSTRUCTIONS:
            svg_path = ASSETS_DIR / f"{word['id']}.svg"
            if not svg_path.exists():
                instructions = VISUAL_INSTRUCTIONS[word_key]
                save_svg_from_instructions(word['id'], instructions['svg'])
                count += 1
                print(f"✓ Saved predefined SVG for {word['german']} ({word['id']})")

    print(f"\nUsed {count} predefined SVGs")
    return count


def show_status():
    """Show overall progress."""
    all_words = get_all_words()
    existing_svgs = get_svg_files()

    print("=" * 60)
    print("SVG CREATION PROGRESS FOR DEUTSCH GARDEN")
    print("=" * 60)
    print(f"Total vocabulary words: {len(all_words)}")
    print(f"Total SVG files: {len(existing_svgs)}")

    # Count words with matching SVGs
    svg_set = set(existing_svgs)
    matching = sum(1 for word in all_words if word["id"] in svg_set)

    print(f"Words with SVGs: {matching}")
    print(f"Words missing SVGs: {len(all_words) - matching}")
    print(f"Completion: {matching/len(all_words)*100:.2f}%")

    # Current batch info
    current_batch = load_current_batch()
    if current_batch:
        completed = sum(1 for word in current_batch['words'] if (ASSETS_DIR / f"{word['id']}.svg").exists())
        print(f"\nCurrent batch: {current_batch['batch_id']}")
        print(f"Batch progress: {completed}/{len(current_batch['words'])} words")

    print("=" * 60)


def main():
    """Main function."""
    parser = argparse.ArgumentParser(description="SVG Batch Workflow System")
    parser.add_argument("--new-batch", type=int, help="Create new batch with N words")
    parser.add_argument("--list-batch", action="store_true", help="List current batch")
    parser.add_argument("--instructions", action="store_true", help="Show instructions for current batch")
    parser.add_argument("--use-predefined", action="store_true", help="Use predefined SVGs for current batch")
    parser.add_argument("--status", action="store_true", help="Show overall progress")
    parser.add_argument("--complete", action="store_true", help="Mark current batch as complete")

    args = parser.parse_args()

    ensure_dirs()

    if args.new_batch:
        create_new_batch(args.new_batch)
        list_current_batch()
        show_instructions()
    elif args.list_batch:
        list_current_batch()
    elif args.instructions:
        show_instructions()
    elif args.use_predefined:
        count = use_all_predefined()
        list_current_batch()
    elif args.status:
        show_status()
    elif args.complete:
        batch = load_current_batch()
        if batch:
            batch['status'] = 'completed'
            batch['completed'] = datetime.now().isoformat()
            with open(CURRENT_BATCH_FILE, 'w', encoding='utf-8') as f:
                json.dump(batch, f, indent=2, ensure_ascii=False)
            print(f"Marked batch {batch['batch_id']} as completed")
            show_status()
        else:
            print("No current batch to complete")
    else:
        # Default: show status
        show_status()


if __name__ == "__main__":
    main()
