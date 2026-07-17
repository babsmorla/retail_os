// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "@hotwired/turbo-rails"
import "controllers"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

console.log("APPLICATION JS LOADED")

document.addEventListener("turbo:load", () => {
  const canvas = document.getElementById("revenueChart")
  if (!canvas) return

  const data = JSON.parse(canvas.dataset.chart)

  if (canvas.chart) {
    canvas.chart.destroy()
  }

  canvas.chart = new Chart(canvas, {
    type: "line",
    data: {
      labels: data.labels,
      datasets: [
        {
          label: "Revenue",
          data: data.values,

          // 1. Line styling (Sharp and vibrant)
          tension: 0, // 0 = straight lines, no curves like the image
          borderWidth: 3,
          borderColor: "#1e60ff", // Vibrant blue
          fill: true,

          // 2. Beautiful permanent "Donut" points
          pointRadius: 5,
          pointBackgroundColor: "#1e60ff",
          pointBorderColor: "#ffffff",
          pointBorderWidth: 2.5,

          // Hover state stays clean and matching
          pointHoverRadius: 7,
          pointHoverBackgroundColor: "#1e60ff",
          pointHoverBorderColor: "#ffffff",
          pointHoverBorderWidth: 3,

          // 3. Perfect Fading Gradient
          backgroundColor: (context) => {
            const chart = context.chart
            const { ctx, chartArea } = chart

            if (!chartArea) return null

            const gradient = ctx.createLinearGradient(0, chartArea.top, 0, chartArea.bottom)
            gradient.addColorStop(0, "rgba(30, 96, 255, 0.22)")  // Stronger top blue
            gradient.addColorStop(1, "rgba(30, 96, 255, 0.00)")  // Smooth fade to transparent
            return gradient
          }
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,

      interaction: {
        intersect: false,
        mode: "index"
      },

      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          backgroundColor: "#0f172a",
          titleColor: "#94a3b8",
          titleFont: {
            size: 11,
            family: "Inter, system-ui, sans-serif",
            weight: "500"
          },
          bodyColor: "#ffffff",
          bodyFont: {
            size: 14,
            family: "Inter, system-ui, sans-serif",
            weight: "700"
          },
          padding: 12,
          cornerRadius: 8,
          displayColors: false,
          borderWidth: 1,
          borderColor: "rgba(255, 255, 255, 0.08)",
          callbacks: {
            label: (context) => {
              return "GH₵ " + context.parsed.y.toLocaleString(undefined, {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
              })
            }
          }
        }
      },

      scales: {
        // 4. Ultra-clean axes configurations
        x: {
          grid: {
            display: false // No vertical gridlines
          },
          border: {
            display: false // No solid X-axis line
          },
          ticks: {
            color: "#64748b", // Subtle gray for month names
            padding: 15,
            font: {
              size: 12,
              weight: "500",
              family: "Inter, system-ui, sans-serif"
            }
          }
        },
        y: {
          display: false, // Hides Y-axis values and lines completely for a minimalist look
          beginAtZero: false // Allows the line to naturally fill the vertical space
        }
      }
    }
  })
})