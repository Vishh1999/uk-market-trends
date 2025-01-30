# UK Market Trends

## Introduction
Welcome to the UK Market Trends project! This initiative is designed to explore and analyze trends in UK markets using the National Market Traders Federation (NMTF) dataset. Through various visualisations, including a composite visualisation, this project aims to answer key questions about market operations, such as:
- How are different market types distributed geographically?
- What are the patterns in stall occupancy by day of the week?
- How do market type and ownership influence average stalls occupied?

Key insights include the dominance of retail markets, regional disparities in market representation, and temporal trends in market activity, with Sundays and Mondays being the busiest days.

## Dataset Description
The dataset, provided by the National Market Traders Federation (NMTF), includes data from 763 UK markets collected between 2016 and 2019. Key features of the dataset include:

- **Market Operation Days**: Indicators for market activity on specific days of the week.
- **Stall Information**: Data on stalls available, occupied, and actively trading for each day.
- **Market Attributes**: Regional data, market types, geographical coordinates, and rental details.

This dataset provides a rich source for understanding market trends and dynamics across the UK.

## Composite Visualization
The composite visualisation combines multiple plots to provide a comprehensive view of UK market trends:
1. **Spatial Plot**: Shows the geographical distribution of markets.
2. **Bar Chart**: Illustrates the average stalls occupied by market type and ownership type.
3. **Heatmap**: Displays weekly trends in market occupancy.
4. **Scatter Plot**: Examines the relationship between market type, average stalls occupied, and regional variations.

These visualisations collectively answer the research questions and provide actionable insights for stakeholders.

## Steps to Run the Code
### 1. Prerequisites
Before running the code, ensure the following software is installed:
- **R** (version 4.0 or later)
- **RStudio** (optional but recommended)
- **Git** (to clone the repository)

### 2. Clone the Repository and Verify Branch
Download the project files by cloning the repository to your local machine by running the following command:

`git clone https://github.com/Vishh1999/uk-market-trends.git`

After cloning, verify that the active Git branch is set to main:
Run the following command to check the current branch:

`git branch`

If the output shows * main,\
you can proceed to the next step.

If the branch is not set to main, switch to the main branch using the following command:

`git checkout main`

This ensures you are working on the correct branch for the project.

### 3. Dataset Placement
Ensure that the dataset `nmftmarkets.xlsx` is placed in the root directory of the cloned repository.

### 4. Execute the Script
Open `code.R` in RStudio or any preferred IDE and run the script to generate:
- Spatial Plot
- Bar Chart
- Heatmap
- Scatter Plot
- Composite Visualisation

### 5. Outputs
Already generated visualisations are saved in the `images` directory. The outputs include:
- `bar_plot.png`
- `heatmap.png`
- `scatter_plot.png`
- `composite_visualisation.png`

The spatial plot is visible in the Viewer Tab of RStudio where it can be interacted with further.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Contact
For queries or further information, please contact:

Name: Vishak LV\
Email: lvvishak@gmail.com\
GitHub: https://github.com/Vishh1999
