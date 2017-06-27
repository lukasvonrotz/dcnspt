# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

User.create(id: '1', email: 'admin@dcnspt.com', password: "electre", password_confirmation: "electre")

p = Project.create(name: 'Example Project', loclat: '46.8483', loclon: '9.5209', startdate: '01.02.2017', enddate: '15.01.2017',
               effort: '60', hourlyrate: '200', user_id: '1')

Criterioncontext.create(name: 'location')
Criterioncontext.create(name: 'costrate')
Criterioncontext.create(name: 'seniority')
Criterioncontext.create(name: 'skill')
Criterioncontext.create(name: 'interest')
Criterioncontext.create(name: 'other')

Jobprofile.create(code: 'JP_Java_SoftEng', name: '.NET Developer')
Jobprofile.create(code: 'JP_.NET_SoftEng', name: 'Java Developer')

Criterion.create(criterioncontext_id: 1, name: 'location')
Criterion.create(criterioncontext_id: 2, name: 'costrate')
Criterion.create(criterioncontext_id: 3, name: 'seniority')
Criterion.create(criterioncontext_id: 4, name: '.NET')
Criterion.create(criterioncontext_id: 4, name: 'java')
Criterion.create(criterioncontext_id: 4, name: 'ethernet')
Criterion.create(criterioncontext_id: 4, name: 'HTTP')
Criterion.create(criterioncontext_id: 5, name: 'RS232')
Criterion.create(criterioncontext_id: 5, name: 'RS485')
Criterion.create(criterioncontext_id: 5, name: 'web development')

Employee.create(firstname: 'Anna', surname: 'Unknown', code: 'anna', loclat: '47.4631', loclon: '8.5322',
                city: 'Rümlang', location: 'Schlieren', country: 'Switzerland', costrate: '120', jobprofile_id: 1)
Employee.create(firstname: 'Jack', surname: 'Unknown', code: 'jack', loclat: '47.2776', loclon: '8.3073',
                city: 'Bilten', location: 'Schlieren', country: 'Switzerland', costrate: '130', jobprofile_id: 2)
Employee.create(firstname: 'John', surname: 'Unknown', code: 'john', loclat: '47.1501', loclon: '9.0341',
                city: 'Buttwil', location: 'Bern', country: 'Switzerland', costrate: '100', jobprofile_id: 1)


Employee.all.each { |employee| p.employees << employee }


Criterionparam.create(project_id: '1', criterion_id: '1', weight: '0.5', direction: 'false',
                      inthresslo: '0.05', inthresint: '-2000', prefthresslo: '0.15', prefthresint: '-3000',
                      vetothresslo: '0.9', vetothresint: '50000', filterlow: '0', filterhigh: '1000000')
Criterionparam.create(project_id: '1', criterion_id: '4', weight: '0.3', direction: 'true',
                      inthresslo: '0.02', inthresint: '0', prefthresslo: '0.05', prefthresint: '0',
                      filterlow: '0', filterhigh: '1000')
Criterionparam.create(project_id: '1', criterion_id: '5', weight: '0.2', direction: 'true',
                      inthresslo: '0', inthresint: '100', prefthresslo: '0', prefthresint: '200',
                      filterlow: '0', filterhigh: '1000000')

Criterionvalue.create(employee_id: '1', criterion_id: '4', value: '206')
Criterionvalue.create(employee_id: '1', criterion_id: '5', value: '203')
Criterionvalue.create(employee_id: '2', criterion_id: '4', value: '205')
Criterionvalue.create(employee_id: '2', criterion_id: '5', value: '265')
Criterionvalue.create(employee_id: '3', criterion_id: '4', value: '123')
Criterionvalue.create(employee_id: '3', criterion_id: '5', value: '120')

Week.create(workweek: '1', year:'2017')
Week.create(workweek: '2', year:'2017')

Workload.create(employee_id: '1', week_id: '1', free: '30', offered: '5', sold: '0', absent: '5')
Workload.create(employee_id: '1', week_id: '2', free: '35', offered: '5', sold: '0', absent: '0')
Workload.create(employee_id: '2', week_id: '1', free: '30', offered: '10', sold: '0', absent: '0')
Workload.create(employee_id: '2', week_id: '2', free: '35', offered: '0', sold: '0', absent: '5')
Workload.create(employee_id: '3', week_id: '1', free: '25', offered: '0', sold: '0', absent: '15')
Workload.create(employee_id: '3', week_id: '2', free: '35', offered: '5', sold: '0', absent: '0')
