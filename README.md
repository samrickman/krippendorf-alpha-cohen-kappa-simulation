# Inter-rater reliability confidence interval simulations

I am going to be calculating inter-rater reliability with binary, imbalanced data (approximately 90% negative class, 10% positive class). This means asking an individual to manually code a number of sentences that have already been coded. I will then measure the agreement rate using:

1. Cohen's Kappa
2. Krippendorf's alpha

The purpose of this repo is to simulate data to establish the optimal number of sentences to test. This means trying to minimise the number of sentences that need to be manually classified twice, while still achieving an acceptable confidence interval for the estimates.

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

It is also notable that with balanced data, the confidence intervals are smaller than with extremely imbalanced data (like a random subset of our data), particularly for Krippendorf's alpha. Further simulations confirm this:

![](./plots/kappa_alpha_comparison/line_plot_prop_negative_class.png)

## Comparison of Krippendorf's alpha confidence intervals using different packages

I originally calculated the confidence intervals for Krippendorf's alpha using [kripp.boot](https://github.com/MikeGruz/kripp.boot). However the size of the confidence intervals did not appear to decline as the sample size increased. I found this surprising although I am not sure if it is expected behaviour so raised this as a [github issue](https://github.com/MikeGruz/kripp.boot/issues/1).

This script calculates alpha using [`kripp.boot`](https://github.com/MikeGruz/kripp.boot) and the [`krippendorffsalpha`](https://github.com/drjphughesjr/krippendorffsalpha) package. In the second case the confidence interval declines as the sample size increases. I discuss this more [here](./kripp_alpha_vs_kripp_boot.md). Apart from when comparing the packages, the estimates in this repo use the `krippendorfsalpha` package rather than `kripp.boot`, as the confidence interval should be sensitive to the sample size.

## Meaning of the term "error rate"

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

Conversely in an imbalanced dataset with perfect agreement between raters, we would have this confusion matrix:

|  | **_Rater 2_** |  |  |  |
|---|---|---|---|---|
| **_Rater 1_** | Class | 0 | 1 |  |
|  | 0 | 80 | 0 |  |
|  | 1 | 0 | 20 |  |

Applying a 0.2 error rate would lead to:

|  | **_Rater 2_** |  |  |  |
|---|---|---|---|---|
| **_Rater 1_** | Class | 0 | 1 |  |
|  | 0 | 64 | 16 |  |
|  | 1 | 4 | 16 |  |

Note that for simplicity I have assumed that the error rate is applied in equal proportions to the negative and positive samples.

## Reproducing this project

Clone the project by running in a terminal:

```bash
git clone https://github.com/samrickman/krippendorf-alpha-cohen-kappa-simulation
```

The data is generated in R `4.1`, with no additional packages. However, the estimates of alpha and Kappa use packages, as does reshaping and plotting. The versions are listed in [`renv.lock`](./renv.lock). The easiest thing is to use [`renv`](https://rstudio.github.io/renv/articles/renv.html) to ensure you have the same package versions. The first time you run the project you will need to open an R terminal in this directory and run:

```r
renv::restore()
```

You should then be able to run any of the simulations by running the relevant R scripts. These files are:

1. [`1__k_alpha_sim_sample_size_balanced.R`](./1__k_alpha_sim_sample_size_balanced.R) Comparison of Krippendorf's alpha confidence intervals calculated by [kripp.boot](https://github.com/MikeGruz/kripp.boot) and [`krippendorffsalpha`](https://github.com/drjphughesjr/krippendorffsalpha) packages. Simulation holds class balance constant at 0.5 and error rate constant at 0.2 and changes the number of samples.
2. [`2_k_alpha_sim_sample_size_imbalanced.R`](./2_k_alpha_sim_sample_size_imbalanced.R) Comparison of Krippendorf's alpha confidence intervals calculated by [kripp.boot](https://github.com/MikeGruz/kripp.boot) and [`krippendorffsalpha`](https://github.com/drjphughesjr/krippendorffsalpha) packages. Simulation holds class balance constant at 0.9 and error rate constant at 0.2 and changes the number of samples.
3. [`3_k_alpha_sim_error_rate.R`](./3_k_alpha_sim_error_rate.R) Comparison of Krippendorf's alpha confidence intervals calculated by [kripp.boot](https://github.com/MikeGruz/kripp.boot) and [`krippendorffsalpha`](https://github.com/drjphughesjr/krippendorffsalpha) packages. Simulation holds class balance constant at 0.5 and number of samples at 300 and changes the error rate.
4. [`4_kappa_alpha_balanced_sim.R`](./4_kappa_alpha_balanced_sim.R) Comparison of Krippendorf's alpha and Cohen's kappa. Simulation holds class balance constant at 0.5 and number of samples at 300 and changes the error rate.
5. [`5_kappa_alpha_imbalanced_sim.R`](./5_kappa_alpha_imbalanced_sim.R) Comparison of Krippendorf's alpha and Cohen's kappa. Simulation holds class balance constant at 0.9 and number of samples at 300 and changes the error rate.
6. [`6_kappa_alpha_balanced_error_rate_sim.R`](./6_kappa_alpha_balanced_error_rate_sim.R) Comparison of Krippendorf's alpha and Cohen's kappa. Simulation holds class balance constant at 0.5 and number of samples at 300 and changes the error rate.
7. [`7_kappa_alpha_imbalanced_error_rate_sim.R`](./7_kappa_alpha_imbalanced_error_rate_sim.R) Comparison of Krippendorf's alpha and Cohen's kappa. Simulation holds class balance constant at 0.9 and number of samples at 300 and changes the error rate.
8. [`8_kappa_alpha_balance_sim.R`](./8_kappa_alpha_balance_sim.R) Comparison of Krippendorf's alpha and Cohen's kappa. Simulation holds error rate constant at 0.2 and number of samples at 300 and changes the class balance.