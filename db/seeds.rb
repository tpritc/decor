# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Component Types
component_types = [
  "CPU",
  "Memory",
  "Disk Controller",
  "Disk",
  "Floppy Controller",
  "Floppy",
  "Tape Controller",
  "Tape Drive",
  "Network Controller",
  "Terminal Line Controller"
]

component_types.each do |name|
  ComponentType.find_or_create_by!(name: name)
end

# Computer Models
computer_models = [
  "MicroVAX II",
  "MicroVAX I",
  "MicroPDP-11/73",
  "VAX-11/750"
]

computer_models.each do |name|
  ComputerModel.find_or_create_by!(name: name)
end

# Conditions
conditions = [
  "Completely original",
  "Original with options replaced or removed",
  "Modified",
  "Frankencomputer"
]

conditions.each do |name|
  Condition.find_or_create_by!(name: name)
end

# Run Statuses
run_statuses = [
  "Running",
  "Not running",
  "Unknown"
]

run_statuses.each do |name|
  RunStatus.find_or_create_by!(name: name)
end

# Owners
owner = Owner.find_or_create_by!(user_name: "VAXorcist") do |o|
  o.real_name = "Hans-Ulrich Hölscher"
  o.website = nil
  o.email = "vaxorcist@decor.org"
  o.password = "password123" # placeholder password for seed data
  o.country = "DE" # Germany
  o.real_name_visibility = :public
  o.country_visibility = :public
  o.email_visibility = :members_only
  o.admin = true
end

owner = Owner.find_or_create_by!(user_name: "rob") do |o|
  o.real_name = "Rob Pritchard"
  o.website = nil
  o.email = "rob_pritchard@outlook.com"
  o.password = "password" # placeholder password for seed data
  o.country = "GB" # United Kingdom
  o.real_name_visibility = :public
  o.country_visibility = :private
  o.email_visibility = :members_only
  o.admin = true
end

# Computers
computer = Computer.find_or_create_by!(
  owner: owner,
  serial_number: "AY80801921"
) do |c|
  c.computer_model = ComputerModel.find_by!(name: "MicroVAX II")
  c.description = "630QY-A3"
  c.condition = Condition.find_by!(name: "Original with options replaced or removed")
  c.run_status = RunStatus.find_by!(name: "Unknown")
  c.history = "Used as a laboratory computer in a state agency from 1985 onwards; decommissioning date unknown, donated in 2008."
end

# Components for the MicroVAX II
components_data = [
  { type: "CPU", description: "KA630" },
  { type: "Memory", description: "MS630 4MB" },
  { type: "Memory", description: "MS630 4MB" },
  { type: "Disk Controller", description: "RQDX3" },
  { type: "Disk", description: "RD54" },
  { type: "Tape Controller", description: "TQK50" },
  { type: "Tape Drive", description: "TK50" },
  { type: "Network Controller", description: "DELQA" },
  { type: "Terminal Line Controller", description: "DZV11" }
]

components_data.each do |data|
  Component.find_or_create_by!(
    owner: owner,
    computer: computer,
    component_type: ComponentType.find_by!(name: data[:type]),
    description: data[:description]
  )
end

puts "Seeded #{ComponentType.count} component types"
puts "Seeded #{ComputerModel.count} computer models"
puts "Seeded #{Owner.count} owners"
puts "Seeded #{Computer.count} computers"
puts "Seeded #{Component.count} components"
