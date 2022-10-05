rm(list = ls())

library(krippendorffsalpha)
library(kripp.boot)
library(ggplot2)
library(ggthemes)
library(tidyr)
library(dplyr)
source("./__simulation_functions.R")

# Simulation of Krippendorf's alpha from 50 to 3000 samples
# with 300 samples and balanced data

error_rates <- seq(from = 0.1, to = 1, by = 0.1)



kappa_alpha_list <- lapply(error_rates, \(error_rate) {
    irr_matrix <- generate_dummy_rater_data(
        error_rate = error_rate,
        prop_negative_class = 0.5
    )
    c(
        "error_rate" = error_rate,
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
        -error_rate,
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
        id_cols = c(error_rate, package),
        names_from = "measure"
    )

# Plot parameters
nudge_x <- rep(c(0, 0.02), nrow(alpha_long))
plot_title <- paste0(
    "Change in Krippendorf's alpha confidence interval with varying error rate"
)
plot_subtitle <- "0.5 negative class, 300 samples"
plot_caption <- "Note: some randomness as confidence estimates created with bootstrapping"

ggplot(alpha_long, mapping = aes(
    x = error_rate
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
        x = "Error rate",
        y = "alpha (line represents CI)",
        caption = plot_caption
    ) +
    scale_color_stata() +
    theme(
        legend.title = element_blank()
    )

ggsave("./plots/kripp_alpha_comparison/boot_kap_lineplot_error_rate.png", w = 12, h = 7.5)

ggplot(alpha_long) +
    geom_point(
        mapping = aes(
            x = error_rate,
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
    expand_limits(x = 0, y = 0) +
    scale_color_stata() +
    theme(
        legend.title = element_blank()
    )

ggsave("./plots/kripp_alpha_comparison/boot_kap_ci_scatter_error_rate.png", w = 12, h = 7.5)

write.csv(alpha_long, "./simulated_data/3_alpha_sim_error_rate.csv", row.names = FALSE)