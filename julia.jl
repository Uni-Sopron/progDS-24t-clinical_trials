using CSV
using DataFrames
using Statistics
using StatsBase
using Plots
using StatsPlots

function load_data(file_path)
    return CSV.read(file_path, DataFrame)
end

function display_basic_info(df)
    println("Number of rows: ", nrow(df))
    println("Number of columns: ", ncol(df))
    println("Column names: ", names(df))
end

function display_summary_statistics(df)
    println("Summary statistics for numeric columns:")
    println(describe(df))
end

function filter_by_enrollment(df, max_enrollment)
    return filter(row -> row.Enrollment <= max_enrollment, df)
end

function plot_histogram(df, max_enrollment, num_bins, output_file)
    enrollment_min = minimum(df.Enrollment)
    enrollment_max = maximum(df.Enrollment)
    bin_width = (enrollment_max - enrollment_min) / num_bins
    bin_edges = enrollment_min:bin_width:enrollment_max
    histogram(df.Enrollment, bins=bin_edges, xlabel="Enrollment", ylabel="Frequency", title="Histogram of Enrollment (Max $(max_enrollment))")
    savefig(output_file)
end

function plot_trial_status(df, output_file)
    temporary_df = filter(row -> row.Status != "Completed", df)
    status_counts = StatsBase.countmap(temporary_df.Status)
    bar(collect(keys(status_counts)), collect(values(status_counts)), xlabel="Status", ylabel="Count", title="Trial Status", xticks=:auto, xrotation=45)
    savefig(output_file)
end

function display_top_sponsors(df, top_n)
    sponsor_counts = StatsBase.countmap(df.Sponsor)
    sorted_sponsors = sort(collect(sponsor_counts), by=x->x[2], rev=true)
    println("Top $(top_n) Sponsors:")
    for (sponsor, count) in sorted_sponsors[1:top_n]
        println("$sponsor: $count trials")
    end
end

function display_trial_phase_distribution(df)
    phase_counts = StatsBase.countmap(df.Phase)
    println("\nTrial Phase Distribution:")
    for (phase, count) in phase_counts
        println("$phase: $count trials")
    end
end

function plot_temporal_analysis(df, output_file)
    start_year_counts = StatsBase.countmap(string.(df.Start_Year))
    sorted_years = sort(collect(keys(start_year_counts)), by=x->parse(Int, x))
    bar(sorted_years, [start_year_counts[year] for year in sorted_years], xlabel="Start Year", ylabel="Number of Trials", title="Clinical Trials by Start Year")
    savefig(output_file)
end

function analyze_summary_length(df)
    df[!,:Summary_Length] = length.(df[:,:Summary])
    avg_summary_length = mean(df[:,:Summary_Length])
    println("\nAverage Summary Length: ", avg_summary_length)
end

function display_top_conditions(df, top_n)
    condition_counts = StatsBase.countmap(df.Condition)
    sorted_conditions = sort(collect(condition_counts), by=x->x[2], rev=true)
    println("\nTop $(top_n) Conditions:")
    for (condition, count) in sorted_conditions[1:top_n]
        println("$condition: $count trials")
    end
end

function plot_enrollment_by_phase(df, output_file)
    boxplot(df.Phase, df.Enrollment, xlabel="Phase", ylabel="Enrollment", title="Enrollment by Trial Phase", xticks=:auto, xrotation=45)
    savefig(output_file)
end

df = load_data("clinical_trials.csv")
display_basic_info(df)
display_summary_statistics(df)

max_enrollment = 2000
filtered_df = filter_by_enrollment(df, max_enrollment)
plot_histogram(filtered_df, max_enrollment, 20, "histogram_enrollment_max.png")
plot_trial_status(df, "bar_chart_trial_status.png")
display_top_sponsors(df, 5)
display_trial_phase_distribution(df)
plot_temporal_analysis(df, "temporal_analysis_start_year.png")
analyze_summary_length(df)
display_top_conditions(df, 5)
plot_enrollment_by_phase(filtered_df, "enrollment_analysis_by_phase.png")
