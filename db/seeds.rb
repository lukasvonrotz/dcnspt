# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Criterioncontext.create(name: 'seniority')
Criterioncontext.create(name: 'skill')
Criterioncontext.create(name: 'interest')
Criterioncontext.create(name: 'other')

#Testdata
Employee.create(firstname: 'Lukas', surname: 'von Rotz', loclat: '47.56', loclon: '5.56', country: 'Switzerland', costrate: '140', jobprofile: 'Software Engineer')
Employee.create(firstname: 'Oscar', surname: 'Meier', loclat: '47.56', loclon: '5.56', country: 'Switzerland', costrate: '40', jobprofile: 'CTO')
Employee.create(firstname: 'Adrian', surname: 'Kölliker', loclat: '47.56', loclon: '5.56', country: 'Switzerland', costrate: '120', jobprofile: 'Software Engineer')
Employee.create(firstname: 'Mirjam', surname: 'Läderach', loclat: '47.56', loclon: '5.56', country: 'Switzerland', costrate: '100', jobprofile: 'Teaching Assistant')
Employee.create(firstname: 'Alexandra', surname: 'Barden', loclat: '47.56', loclon: '5.56', country: 'Germany', costrate: '110', jobprofile: 'Project Assistant')
Employee.create(firstname: 'Matthias', surname: 'Stürmer', loclat: '47.56', loclon: '5.56', country: 'Switzerland', costrate: '200', jobprofile: 'Project Leader')
Employee.create(firstname: 'Janik', surname: 'Endtner', loclat: '47.56', loclon: '5.56', country: 'Switzerland', costrate: '130', jobprofile: 'Software Engineer')

Criterion.create(criterioncontext_id: 4, name: 'consumption')
Criterion.create(criterioncontext_id: 4, name: 'price')
Criterion.create(criterioncontext_id: 4, name: 'comfort')
Criterion.create(criterioncontext_id: 4, name: 'speed')
Criterion.create(criterioncontext_id: 1, name: 'seniority')
Criterion.create(criterioncontext_id: 2, name: 'skill1')
Criterion.create(criterioncontext_id: 2, name: 'skill2')
Criterion.create(criterioncontext_id: 2, name: 'skill3')
Criterion.create(criterioncontext_id: 3, name: 'interest1')
Criterion.create(criterioncontext_id: 3, name: 'interest2')
Criterion.create(criterioncontext_id: 3, name: 'interest3')

Criterionvalue.create(employee_id: '1', criterion_id: '1', value: '8.3')
Criterionvalue.create(employee_id: '1', criterion_id: '2', value: '3.17')
Criterionvalue.create(employee_id: '1', criterion_id: '3', value: '13')
Criterionvalue.create(employee_id: '1', criterion_id: '4', value: '15.7')
Criterionvalue.create(employee_id: '2', criterion_id: '1', value: '8.7')
Criterionvalue.create(employee_id: '2', criterion_id: '2', value: '2.8')
Criterionvalue.create(employee_id: '2', criterion_id: '3', value: '14')
Criterionvalue.create(employee_id: '2', criterion_id: '4', value: '15')
Criterionvalue.create(employee_id: '3', criterion_id: '1', value: '7')
Criterionvalue.create(employee_id: '3', criterion_id: '2', value: '3.55')
Criterionvalue.create(employee_id: '3', criterion_id: '3', value: '12')
Criterionvalue.create(employee_id: '3', criterion_id: '4', value: '14')
Criterionvalue.create(employee_id: '4', criterion_id: '1', value: '8')
Criterionvalue.create(employee_id: '4', criterion_id: '2', value: '1.65')
Criterionvalue.create(employee_id: '4', criterion_id: '3', value: '6')
Criterionvalue.create(employee_id: '4', criterion_id: '4', value: '12')
Criterionvalue.create(employee_id: '5', criterion_id: '1', value: '11')
Criterionvalue.create(employee_id: '5', criterion_id: '2', value: '6.5')
Criterionvalue.create(employee_id: '5', criterion_id: '3', value: '19')
Criterionvalue.create(employee_id: '5', criterion_id: '4', value: '19.5')
Criterionvalue.create(employee_id: '6', criterion_id: '5', value: '4')
Criterionvalue.create(employee_id: '6', criterion_id: '6', value: '11')
Criterionvalue.create(employee_id: '6', criterion_id: '7', value: '12')
Criterionvalue.create(employee_id: '6', criterion_id: '8', value: '13')
Criterionvalue.create(employee_id: '6', criterion_id: '9', value: '21')
Criterionvalue.create(employee_id: '6', criterion_id: '10', value: '22')
Criterionvalue.create(employee_id: '6', criterion_id: '11', value: '23')

Project.create(name: 'Projekt1', loclat: '45.55', loclon: '6.54', startdate: '01.01.2017', enddate: '20.02.2017', effort: '30', hourlyrate: '200', user_id: '1')
Project.create(name: 'Projekt2', loclat: '45.55', loclon: '6.54', startdate: '01.01.2017', enddate: '20.02.2017', effort: '30', hourlyrate: '200', user_id: '1')

Criterionparam.create(project_id: '1', criterion_id: '1', weight: '0.2', preferencethreshold: '1', indifferencethreshold: '2', vetothreshold: '3')
Criterionparam.create(project_id: '1', criterion_id: '2', weight: '0.2', preferencethreshold: '4', indifferencethreshold: '5', vetothreshold: '6')
Criterionparam.create(project_id: '1', criterion_id: '3', weight: '0.2', preferencethreshold: '7', indifferencethreshold: '8', vetothreshold: '9')
Criterionparam.create(project_id: '1', criterion_id: '4', weight: '0.2', preferencethreshold: '10', indifferencethreshold: '11', vetothreshold: '12')
Criterionparam.create(project_id: '2', criterion_id: '5', weight: '0.1', preferencethreshold: '1', indifferencethreshold: '2', vetothreshold: '3')
Criterionparam.create(project_id: '2', criterion_id: '6', weight: '0.1', preferencethreshold: '4', indifferencethreshold: '5', vetothreshold: '6')
Criterionparam.create(project_id: '2', criterion_id: '7', weight: '0.05', preferencethreshold: '7', indifferencethreshold: '8', vetothreshold: '9')
Criterionparam.create(project_id: '2', criterion_id: '8', weight: '0.05', preferencethreshold: '1', indifferencethreshold: '2', vetothreshold: '3')
Criterionparam.create(project_id: '2', criterion_id: '9', weight: '0.1', preferencethreshold: '4', indifferencethreshold: '5', vetothreshold: '6')
Criterionparam.create(project_id: '2', criterion_id: '10', weight: '0.25', preferencethreshold: '7', indifferencethreshold: '8', vetothreshold: '9')
Criterionparam.create(project_id: '2', criterion_id: '11', weight: '0.25', preferencethreshold: '10', indifferencethreshold: '11', vetothreshold: '12')

Week.create(workweek: '49', year:'2016')
Week.create(workweek: '50', year:'2016')
Week.create(workweek: '51', year:'2016')
Week.create(workweek: '52', year:'2016')
Week.create(workweek: '1', year:'2017')
Week.create(workweek: '2', year:'2017')
Week.create(workweek: '3', year:'2017')
Week.create(workweek: '4', year:'2017')
Week.create(workweek: '5', year:'2017')
Week.create(workweek: '6', year:'2017')
Week.create(workweek: '7', year:'2017')
Week.create(workweek: '8', year:'2017')
Week.create(workweek: '9', year:'2017')
Week.create(workweek: '10', year:'2017')

Workload.create(employee_id: '1', week_id: '1', free: '5', offered: '10', sold: '15', absent: '20')
Workload.create(employee_id: '1', week_id: '2', free: '10', offered: '15', sold: '20', absent: '25')
Workload.create(employee_id: '2', week_id: '1', free: '15', offered: '20', sold: '25', absent: '30')
Workload.create(employee_id: '2', week_id: '2', free: '0', offered: '5', sold: '10', absent: '15')