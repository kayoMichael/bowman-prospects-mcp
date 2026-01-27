# Bowman Prospects Classification MCP Server

This MCP Server gives the tools to classify Bowman Prospects Baseball cards (Chrome or Paper) to determine their current and future value. It allows Claude to access 3 tools to analyze baseball cards through image recognition (contrastive loss), player statistics, and market pricing data.

## Available Tools

- **Card Classification** — Identifies card details from images using a fine-tuned [CLIP model](https://openai.com/index/clip/) (~12,000 training samples) combined with EasyOCR. Extracts rarity (Chrome, Blue, Atomic, etc.), player information, grading status, and other key attributes.

- **Player Statistics** — Retrieves comprehensive career statistics across Major League and Minor League levels, including advanced metrics (WAR, DRS, OPS+, etc.) for evaluating player potential and production.

- **Pricing Data** — Provides current market prices and sales volume for the specific card and grade.

## Fine-tuned CLIP Model
The model is fine-tuned using ~12,000 labeled bowman prospects image scrapped and categorized from Ebay. The model can be downloaded from [here](https://huggingface.co/hazelbestt/bowman_prospects_classifier)

It currently holds a 90.84% accuracy rate in identifying the rarity of bowman prospects cards.

## Data

### Source
The Relevant Data is fetched from multiple websites:
- Card Pricing: https://www.sportscardspro.com/category/baseball-cards
- Player Statistics: https://www.baseball-reference.com/register/index.fcgi
- Player Global IDs: https://raw.githubusercontent.com/chadwickbureau/register/master/
- Baseball Card Images: https://www.ebay.ca/

### Dataset
The library fetches the complete dataset for training from here: https://huggingface.co/datasets/hazelbestt/bowman_prospects_supervised_images

### Parse
The raw HTML content is then parsed using [DeepSeek API](https://www.deepseek.com/) for reliability against page structure changes.
You can see the relevant LLM Prompt here: [prompt](https://github.com/kayoMichael/bowman-prospects-mcp/blob/main/context/const/prompt.py)

## Running the MCP
1. Install [Claude Desktop](https://code.claude.com/docs/en/desktop)
2. Clone the Repository
3. Install Dependencies
```bash
pip install -r requirements.txt
```
4. Fill in the env file
5. Run via Make
```bash
make run-mcp
```
6. Follow this [Guide](https://modelcontextprotocol.io/docs/develop/connect-local-servers) to connect the MCP to Claude Desktop


## Training the Model
The MCP comes pre-built with a Model and the Dataset required to classify images with relative accuracy. But users can train on top of the current model.

### Docker (CPU only)
```bash
make train-cpu
```

### Using GPU
```bash
make train-mps
```

### Configurable Flags for Training
- LR: Learning rate (default: 5e-6)
- EPOCHS: Number of epochs (default: 15)
- BATCH_SIZE: Batch size (default: 2)
- ACC_STEPS: Gradient accumulation steps (default: 4)
- CUSTOM: Use custom local dataset instead of HuggingFace dataset (0 or 1, default: 0)
- FETCH: Fetch dataset images before training (0 or 1, default: 0)
- RESET: Reset model weights to the base [checkpoint](https://huggingface.co/hazelbestt/bowman_prospects_classifier) before training (0 or 1, default: 0)

#### Example
```
make train-mps LR=1e-5 EPOCHS=5 BATCH_SIZE=4 ACC_STEPS=2 CUSTOM=1 FETCH=1 RESET=1
```

### Custom Datasets
To train the model with a custom dataset, create a data_set directory in the root of the project. Then store images with directories as labels

e.g.
```
data_set/
└── chrome/
    └── aqua/
        └── non_auto/
            ├── 2018 Bowman Chrome Prospects Aqua Refractor _125 Adam Haseley _BCP94.jpg
            ├── 2018 Bowman Chrome Prospects Refractors Aqua Shimmer Adam Haseley Phillies _125.jpg
            └── 2018 Bowman _BCP80 Matt Hall Chrome Prospects Aqua Refractor __125.jpg
```

The file name of the images do not matter.

## Sample Workflow

### Input

As an Example, we connect the MCP server to Claude and give the image paths to the following image. (Note: As of November 20, 2025, local MCP does not support attaching images directly to Claude Desktop.)

<p float="left">
  <img src="https://github.com/user-attachments/assets/399ddadd-20ff-4df5-bf2b-ddc2ac23d4fc" width="200" />
  <img src="https://github.com/user-attachments/assets/a82a5db7-1fce-4616-ab6a-aa0bdfce313b" width="200" />
</p>

### Output

<img width="1512" height="619" alt="Screenshot 2025-11-20 at 12 25 45 AM" src="https://github.com/user-attachments/assets/228a9f69-649d-4324-b228-a9fa04a1d3b1" />
<img width="1511" height="712" alt="Screenshot 2025-11-20 at 12 26 10 AM" src="https://github.com/user-attachments/assets/7ca56fe9-6c6d-437f-a6cd-42c16a32f990" />
<img width="1512" height="574" alt="Screenshot 2025-11-20 at 12 26 24 AM" src="https://github.com/user-attachments/assets/733533c8-1f79-47d4-b921-30f1be15f8e9" />

### Tool Responses

Below is the raw data returned to Claude by each tool.

#### Predict (Card Classification)

```json
{
  "player_profile": {
    "name": "HYUN-IL CHOI",
    "position": "PITCHER",
    "team": "LOS ANGELES DODGERS",
    "date_of_birth": "05-27-2000",
    "location_of_birth": "SEOUL, SOUTH KOREA",
    "resume": "No. 13 Dodgers prospect (Baseball America). Averaged 9.8 SOs/9 IP in 2019 Arizona League. Forged SO/BB ratio of 6.5-to-1. Led team in wins (tied), innings, and strikeouts.",
    "skills": "Varies speeds and locations cunningly to keep hitters guessing. Loose arm action. Low-90s fastball. Late-breaking hook. Promising change-up. Confident athlete.",
    "up_close": "Top contender to go No. 1 overall in the Korea Baseball Organization draft coming out of high school. Opted to sign with the Dodgers instead."
  },
  "card_info": {
    "card_code": "BCP-130",
    "graded": "Ungraded",
    "serial_number": "Not Numbered",
    "year": 2021,
    "label": "bowman chrome atomic non_auto baseball card"
  }
}
```

#### Prospect (Player Statistics)

```json
{
  "Major League Statistics": null,
  "Minor League Statistics": {
    "player_profile": {
      "name": "Hyun-il Choi",
      "position": "Pitcher",
      "bats": "Right",
      "throws": "Right",
      "height": "6-2",
      "weight": "215lb",
      "birth_date": "May 27, 2000",
      "latest_team": "WSN",
      "status": "minors",
      "draft_info": null
    },
    "season 2019": {
      "current_league_level": "Rk",
      "batting": null,
      "pitching": {
        "w": 5,
        "l": 1,
        "era": 2.63,
        "so": 71,
        "war": null,
        "ip": 65.0,
        "whip": 1.046,
        "G": 14,
        "GS": 11,
        "bb": 11,
        "GF": 0,
        "CG": 0,
        "SV": 0,
        "SHO": 0,
        "HBP": 8,
        "FIP": null,
        "SO9": 9.8,
        "H9": 7.9,
        "HR9": 0.8,
        "WP": 2,
        "SO/BB": 6.45
      }
    },
    "season 2021": {
      "current_league_level": "A/A+",
      "batting": null,
      "pitching": {
        "w": 8,
        "l": 6,
        "era": 3.55,
        "so": 106,
        "war": null,
        "ip": 106.1,
        "whip": 0.969,
        "G": 24,
        "GS": 11,
        "bb": 18,
        "GF": 1,
        "CG": 0,
        "SV": 0,
        "SHO": 0,
        "HBP": 3,
        "FIP": null,
        "SO9": 9.0,
        "H9": 7.2,
        "HR9": 1.0,
        "WP": 4,
        "SO/BB": 5.89
      }
    },
    "season 2022": {
      "current_league_level": "A+/Rk",
      "batting": null,
      "pitching": {
        "w": 0,
        "l": 1,
        "era": 4.5,
        "so": 4,
        "war": null,
        "ip": 4.0,
        "whip": 1.0,
        "G": 2,
        "GS": 1,
        "bb": 0,
        "GF": 0,
        "CG": 0,
        "SV": 0,
        "SHO": 0,
        "HBP": 0,
        "FIP": null,
        "SO9": 9.0,
        "H9": 9.0,
        "HR9": 0.0,
        "WP": 0,
        "SO/BB": null
      }
    },
    "season 2023": {
      "current_league_level": "A+",
      "batting": null,
      "pitching": {
        "w": 4,
        "l": 5,
        "era": 3.75,
        "so": 46,
        "war": null,
        "ip": 60.0,
        "whip": 1.25,
        "G": 16,
        "GS": 13,
        "bb": 12,
        "GF": 0,
        "CG": 0,
        "SV": 0,
        "SHO": 0,
        "HBP": 5,
        "FIP": null,
        "SO9": 6.9,
        "H9": 9.5,
        "HR9": 0.9,
        "WP": 2,
        "SO/BB": 3.83
      }
    },
    "season 2024": {
      "current_league_level": "AA/AAA",
      "batting": null,
      "pitching": {
        "w": 5,
        "l": 11,
        "era": 4.92,
        "so": 102,
        "war": null,
        "ip": 115.1,
        "whip": 1.335,
        "G": 24,
        "GS": 21,
        "bb": 40,
        "GF": 2,
        "CG": 0,
        "SV": 0,
        "SHO": 0,
        "HBP": 14,
        "FIP": null,
        "SO9": 8.0,
        "H9": 8.9,
        "HR9": 1.0,
        "WP": 1,
        "SO/BB": 2.55
      }
    },
    "season 2025": {
      "current_league_level": "AA/AAA",
      "batting": null,
      "pitching": {
        "w": 7,
        "l": 8,
        "era": 4.87,
        "so": 88,
        "war": null,
        "ip": 116.1,
        "whip": 1.221,
        "G": 30,
        "GS": 20,
        "bb": 34,
        "GF": 1,
        "CG": 0,
        "SV": 0,
        "SHO": 0,
        "HBP": 13,
        "FIP": null,
        "SO9": 6.8,
        "H9": 8.4,
        "HR9": 1.8,
        "WP": 3,
        "SO/BB": 2.59
      }
    }
  }
}
```

#### Baseball Card (Pricing Data)

```json
{
  "card_price": {
    "ungraded": "$2.50",
    "grade 1": null,
    "grade 2": null,
    "grade 3": null,
    "grade 4": null,
    "grade 5": null,
    "grade 6": null,
    "grade 7": null,
    "grade 8": null,
    "grade 9": null,
    "grade 9.5": null,
    "TAG 10": null,
    "ACE 10": null,
    "SGC 10": null,
    "CGC 10": null,
    "PSA 10": null,
    "BGS 10": null,
    "BGS 10 Black": null,
    "CGC 10 Pristine": null
  },
  "card_volume": {
    "ungraded sold listings": 5,
    "grade 7 sold listings": 0,
    "grade 8 sold listings": 0,
    "grade 9 sold listings": 0,
    "grade 10 sold listings": 0
  }
}
```
