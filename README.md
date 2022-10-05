# Inter-rater reliability confidence interval simulations

I am going to be calculating inter-rater reliability with imbalanced data (approximately 90% negative class, 10% positive class). This means asking an individual to manually code a number of sentences that have already been coded. I will then measure the agreement rate using:

1. Cohen's Kappa
2. Krippendorf's alpha

The purpose of this repo is to simulate data to establish the optimal number of sentences to test. This means trying to minimise the number of sentences that need to be manually classified twice, while still achieving an acceptable confidence interval.

## Parameters for simulation

The parameters that I will test at different levels:

1. Number of samples, i.e. number of sentences to be manually classified by both raters.
2. Imbalance. Although the raw dataset is imbalanced, it may be desirable to select a more balanced subset of the data, as more samples in the positive class should reduce the uncertainty of the estimate.
3. Error rate. It is unknown what proportion of sentences the raters will disagree on. Once a sample size and imbalance is decided upon, we will want to make sure that the uncertainty is not sensitive to the error rate.

## Results

### Imbalanced data

Although confidence increases with larger samples, Krippendorf’s alpha has wider confidence intervals than Cohen’s Kappa with imbalanced data.

![](./plots/kappa_alpha_comparison/line_plot_num_samples_imbalanced.png)

### Balanced data

This discrepancy disappears with balanced data.

![](./plots/kappa_alpha_comparison/line_plot_num_samples_balanced.png)

It is also notable that with balanced data, the confidence intervals are smaller than at the extremes, particularly for Krippendorf's alpha. Further simulations confirm this:

![](./plots/kappa_alpha_comparison/line_plot_prop_negative_class.png)

## Comparison of Krippendorf's alpha confidence intervals using different packages

I originally calculated the confidence intervals for Krippendorf's alpha using [kripp.boot](https://github.com/MikeGruz/kripp.boot). However the size of the confidence intervals did not appear to decline as the sample size increased. I found this surprising although I am not sure if it is expected behaviour so raised this as a [github issue](https://github.com/MikeGruz/kripp.boot/issues/1).

This script calculates alpha using `kripp.boot` and the [`krippendorffsalpha`](https://github.com/drjphughesjr/krippendorffsalpha) package. In the second case the confidence interval declines as the sample size increases. I discuss this more [here]("./blob/main/kripp_alpha_vs_kripp_boot.md")

## Meaning of the phrase "error rate"

I have used the phrase "error rate" to refer to the proportion of true positives and true negatives that are misclassified. For example, with a balanced dataset of 100 perfectly classified samples, the confusion matrix would be:

|  | **_Rater 2_** |  |  |  |
|---|---|---|---|---|
| **_Rater 1_** | Class | 0 | 1 |  |
|  | 0 | 50 | 0 |  |
|  | 1 | 0 | 50 |  |


If we set the error rate at 0.2, the confusion matrix would be:

|  | **_Rater 2_** |  |  |  |
|---|---|---|---|---|
| **_Rater 1_** | Class | 0 | 1 |  |
|  | 0 | 40 | 10 |  |
|  | 1 | 10 | 40 |  |

This would lead to Krippendorf's alpha and Cohen's Kappa of about 0.6.

## Reproducing this project

Clone the project by running in a terminal:

```bash
git clone https://github.com/samrickman/krippendorf-alpha-cohen-kappa-simulation
```

Once you have done this, in R you will need the [`renv`](https://rstudio.github.io/renv/articles/renv.html) package to ensure you have the same package versions. The first time you run the project you will need to open an R terminal in this directory and run:

```r
renv::restore()
```

You should then be able to run any of the simulations by running the relevant R scripts. These files are:

1. Comparison of Krippendorf's alpha confidence intervals calculated by [kripp.boot](https://github.com/MikeGruz/kripp.boot) and [`krippendorffsalpha`](https://github.com/drjphughesjr/krippendorffsalpha) packages. Simulation holds class balance constant at 0.5 and error rate constant at 0.2 and changes the number of samples.
2. Comparison of Krippendorf's alpha confidence intervals calculated by [kripp.boot](https://github.com/MikeGruz/kripp.boot) and [`krippendorffsalpha`](https://github.com/drjphughesjr/krippendorffsalpha) packages. Simulation holds class balance constant at 0.9 and error rate constant at 0.2 and changes the number of samples.
3. Comparison of Krippendorf's alpha confidence intervals calculated by [kripp.boot](https://github.com/MikeGruz/kripp.boot) and [`krippendorffsalpha`](https://github.com/drjphughesjr/krippendorffsalpha) packages. Simulation holds class balance constant at 0.5 and number of samples at 300 and changes the error rate.
4. Comparison of Krippendorf's alpha and Cohen's kappa. Simulation holds class balance constant at 0.5 and number of samples at 300 and changes the error rate.
5. Comparison of Krippendorf's alpha and Cohen's kappa. Simulation holds class balance constant at 0.9 and number of samples at 300 and changes the error rate.
6. Comparison of Krippendorf's alpha and Cohen's kappa. Simulation holds class balance constant at 0.5 and number of samples at 300 and changes the error rate.
7. Comparison of Krippendorf's alpha and Cohen's kappa. Simulation holds class balance constant at 0.9 and number of samples at 300 and changes the error rate.
8. Comparison of Krippendorf's alpha and Cohen's kappa. Simulation holds error rate constant at 0.2 and number of samples at 300 and changes the class balance.