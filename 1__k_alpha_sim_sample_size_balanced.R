rm(list = ls())

library(krippendorffsalpha)
library(kripp.boot)
library(ggplot2)
library(ggthemes)
library(tidyr)
library(dplyr)
source("./__simulation_functions.R")

# Simulation of Krippendorf's alpha from 50 to 3000 samples
# with error rate 0.2 and imbalanced data - i.e. confusion matrix
#     0   1
# 0 0.4 0.1
# 1 0.1 0.4


# Number of samples
num_samples_choices <- c(
    seq(from = 50, to = 450, by = 50),
    seq(from = 500, to = 900, by = 100),
    seq(from = 1000, to = 5000, by = 500)
)

# Simulate data
kappa_alpha_list <- lapply(num_samples_choices, \(num_samples) {
    irr_matrix <- generate_dummy_rater_data(
        num_samples = num_samples,
        prop_negative_class = 0.5
    )
    c(
        "num_samples" = num_samples,
        compare_bootstrap_estimates(irr_matrix)
    )
})

# Create dataframe
kappa_alpha_df <- bind_rows(kappa_alpha_list) |>
    mutate(
        diff_boot = upper_boot - lower_boot,
        diff_kap = upper_kap - lower_kap
    )

# Make long for plot
alpha_long <- kappa_alpha_df |>
    pivot_longer(
        -num_samples,
        names_to = c("measure", "package"),
        names_sep = "_"
    ) |>
    mutate(
        package = ifelse(
            package == "boot",
            "kripp.boot",
            "krippendorffsalpha"
        )
    ) |>
    pivot_wider(
        id_cols = c(num_samples, package),
        names_from = "measure"
    )

# Plot parameters
alpha_long_for_line_plot <- filter(alpha_long, num_samples <= 500)
nudge_x <- rep(c(0, 10), nrow(alpha_long_for_line_plot))
plot_title <- paste0(
    "Change in confidence interval with n samples at ",
    round(mean(alpha_long$alpha), 2),
    " Krippendorf's alpha"
)
plot_subtitle <- "0.5 negative class, 0.2 error rate"
plot_caption <- "Note: some randomness as confidence estimates created with bootstrapping"

ggplot(alpha_long_for_line_plot, mapping = aes(
    x = num_samples
)) +
    geom_point(
        aes(
            y = alpha,
            color = package
        ),
        position = position_nudge(
            x = nudge_x
        ),
        size = 3
    ) +
    geom_linerange(
        aes(
            ymin = lower,
            ymax = upper,
            color = package
        ),
        position = position_nudge(
            x = nudge_x
        ),
        size = 1.4
    ) +
    expand_limits(x = 0, y = 0) +
    theme_stata(base_size = 16) +
    labs(
        title = plot_title,
        subtitle = plot_subtitle,
        x = "n",
        y = "alpha (line represents CI)",
        caption = plot_caption
    ) +
    scale_color_stata() +
    theme(
        legend.title = element_blank()
    )

ggsave("./plots/kripp_alpha_comparison/boot_kap_lineplot_balanced.png", w = 12, h = 7.5)



ggplot(alpha_long) +
    geom_point(
        mapping = aes(
            x = num_samples,
            y = diff,
            color = package
        ),
        size = 3
    ) +
    theme_stata(base_size = 16) +
    labs(
        title = plot_title,
        subtitle = plot_subtitle,
        x = "n",
        y = "Difference between lower and upper bound",
        caption = "Note: some randomness as confidence estimates created with bootstrapping"
    ) +
    scale_x_continuous(breaks = seq(
        from = 0, to = max(kappa_alpha_df$num_samples), by = 500
    )) +
    expand_limits(x = 0, y = 0) +
    scale_color_stata() +
    theme(
        legend.title = element_blank()
    )

ggsave("./plots/kripp_alpha_comparison/boot_kap_ci_scatter_balanced.png", w = 12, h = 7.5)

# Save data so I don't keep having to run simulations
write.csv(alpha_long, "./simulated_data/1_alpha_balanced.csv", row.names = FALSE)