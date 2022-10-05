rm(list = ls())

library(krippendorffsalpha)
library(kripp.boot)
library(ggplot2)
library(ggthemes)
library(tidyr)
library(dplyr)
library(psych)
source("./__simulation_functions.R")

# Files 1-3 have persuaded me to use the krippendorffsalpha package
# rather than the kripp.boot package


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
        prop_negative_class = 0.9
    )

    c(
        "num_samples" = num_samples,
        get_cohen_kappa(irr_matrix),
        get_k_alpha_kap(irr_matrix)
    )
})


# Create dataframe
kappa_alpha_df <- bind_rows(kappa_alpha_list) |>
    mutate(
        diff_kappa = cohen_k_upper - cohen_k_lower,
        diff_alpha = upper_kap - lower_kap
    )
#####
#
kappa_alpha_long <- kappa_alpha_df |>
    select(
        num_samples,
        estimate_kappa = cohen_k,
        upper_kappa  = cohen_k_upper,
        lower_kappa = cohen_k_lower,
        estimate_alpha = alpha_kap,
        lower_alpha = lower_kap,
        upper_alpha = upper_kap,
        diff_alpha,
        diff_kappa
    ) |>
    pivot_longer(
        -num_samples,
        names_to = c("measure", "greek_letter"),
        names_sep = "_"
    ) |>
    pivot_wider(
        id_cols = c(num_samples, greek_letter),
        names_from = "measure"
    )


# Plot parameters
ka_long_for_line_plot <- filter(kappa_alpha_long, num_samples <= 500)
nudge_x <- rep(c(0, 10), nrow(ka_long_for_line_plot))
plot_title <- "Comparison between Krippendorf's alpha and Cohen's Kappa"
plot_subtitle <- "0.9 negative class, 0.2 error rate"
plot_caption <- "Note: some randomness as confidence estimates created with bootstrapping"


ggplot(ka_long_for_line_plot, mapping = aes(
    x = num_samples
)) +
    geom_point(
        aes(
            y = estimate,
            color = greek_letter
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
            color = greek_letter
        ),
        position = position_nudge(
            x = nudge_x
        ),
        size = 1.4
    ) +
    expand_limits(x = 0, y = 0) +
    coord_cartesian(ylim = (c(0, 1))) +
    theme_stata(base_size = 16) +
    labs(
        title = plot_title,
        subtitle = plot_subtitle,
        x = "Number of samples",
        y = "value (line represents CI)",
        caption = plot_caption
    ) +
    scale_color_stata() +
    theme(
        legend.title = element_blank()
    )


ggsave("./plots/kappa_alpha_comparison/line_plot_num_samples_imbalanced.png", w = 12, h = 7.5)



nudge_x <- rep(c(0, 10), nrow(kappa_alpha_long))

ggplot(kappa_alpha_long) +
    geom_point(
        mapping = aes(
            x = num_samples,
            y = diff,
            color = greek_letter
        ),
        size = 3,
        position = position_nudge(
            x = nudge_x
        ),
    ) +
    theme_stata(base_size = 16) +
    coord_cartesian(ylim = (c(0, 1))) +
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

ggsave("./plots/kappa_alpha_comparison/scatter_num_samples_imbalanced.png", w = 12, h = 7.5)

write.csv(kappa_alpha_long, "./simulated_data/5_kappa_alpha_imbalanced.csv", row.names = FALSE)