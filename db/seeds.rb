# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

User.create(id: 1, email: 'admin@dcnspt.com',
            encrypted_password: '$2a$11$sRxTQev8TpC0yyugrfOn6eRKfKhrFPgPdQPHP0B1gnh1sUvviUmKS');

Project.create(name: 'Example Project', loclat: '46.75', loclon: '8.03', startdate: '01.02.2017', enddate: '15.01.2017',
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
Criterion.create(criterioncontext_id: 4, name: 'Java')
Criterion.create(criterioncontext_id: 4, name: 'Ethernet')
Criterion.create(criterioncontext_id: 4, name: 'HTTP')
Criterion.create(criterioncontext_id: 5, name: 'RS232')
Criterion.create(criterioncontext_id: 5, name: 'RS485')
Criterion.create(criterioncontext_id: 5, name: 'Web Development')

Employee.create(firstname: 'Anna', surname: 'unknown', code: 'anna', loclat: '47.39', loclon: '8.42', city: 'Urdorf',
                location: 'Schlieren', country: 'Switzerland', costrate: '120', jobprofile_id: 1)
Employee.create(firstname: 'Jack', surname: 'unknown', code: 'jack', loclat: '47.37', loclon: '8.54', city: 'Urdorf',
                location: 'Schlieren', country: 'Switzerland', costrate: '130', jobprofile_id: 2)
Employee.create(firstname: 'John', surname: 'unknown', code: 'john', loclat: '46.75', loclon: '7.63', city: 'Urdorf',
                location: 'Bern', country: 'Switzerland', costrate: '100', jobprofile_id: 1)

Criterionparam.create(project_id: '1', criterion_id: '1', weight: '0.5', direction: 'min',
                      inthresslo: '0.05', inthresint: '-2000', prefthresslo: '0.15', prefthresint: '-3000',
                      vetothresslo: '0.9', vetothresint: '50000', filterlow: '0', filterhigh: '110000')
Criterionparam.create(project_id: '1', criterion_id: '5', weight: '0.3', direction: 'max',
                      inthresslo: '0.02', inthresint: '0', prefthresslo: '0.05', prefthresint: '0',
                      filterlow: '100', filterhigh: '1000')
Criterionparam.create(project_id: '1', criterion_id: '4', weight: '0.2', direction: 'max',
                      inthresslo: '0', inthresint: '100', prefthresslo: '0', prefthresint: '200',
                      filterlow: '100', filterhigh: '1000')

Criterionvalue.create(employee_id: '1', criterion_id: '1', value: '101300')
Criterionvalue.create(employee_id: '1', criterion_id: '5', value: '206')
Criterionvalue.create(employee_id: '1', criterion_id: '4', value: '203')
Criterionvalue.create(employee_id: '2', criterion_id: '1', value: '103600')
Criterionvalue.create(employee_id: '2', criterion_id: '5', value: '205')
Criterionvalue.create(employee_id: '2', criterion_id: '4', value: '265')
Criterionvalue.create(employee_id: '3', criterion_id: '1', value: '49900')
Criterionvalue.create(employee_id: '3', criterion_id: '5', value: '123')
Criterionvalue.create(employee_id: '3', criterion_id: '4', value: '120')

Week.create(workweek: '1', year:'2017')
Week.create(workweek: '2', year:'2017')

Workload.create(employee_id: '1', week_id: '1', free: '30', offered: '5', sold: '0', absent: '5')
Workload.create(employee_id: '1', week_id: '2', free: '35', offered: '5', sold: '0', absent: '0')
Workload.create(employee_id: '2', week_id: '1', free: '30', offered: '10', sold: '0', absent: '0')
Workload.create(employee_id: '2', week_id: '2', free: '35', offered: '0', sold: '0', absent: '5')
Workload.create(employee_id: '3', week_id: '1', free: '25', offered: '0', sold: '0', absent: '15')
Workload.create(employee_id: '3', week_id: '2', free: '35', offered: '5', sold: '0', absent: '0')
