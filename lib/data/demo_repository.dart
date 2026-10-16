import 'package:flutter/material.dart';

class Question {
  const Question(this.prompt, this.options, this.answer, this.explanation,
      {required this.semanticId, required this.conceptId});
  final String prompt;
  final List<String> options;
  final int answer;
  final String explanation;
  final String semanticId;
  final String conceptId;
}

class QuestionSeed {
  const QuestionSeed(
      {required this.id,
      required this.conceptId,
      required this.concept,
      required this.misconception,
      required this.scenario,
      required this.distractors});
  final String id, conceptId, concept, misconception, scenario;
  final List<String> distractors;
}

class LessonSpec {
  const LessonSpec(
      {required this.id,
      required this.title,
      required this.objectives,
      required this.seeds});
  final String id, title;
  final List<String> objectives;
  final List<QuestionSeed> seeds;
}

class VideoLesson {
  const VideoLesson(
      {required this.id,
      required this.title,
      required this.duration,
      required this.objectives,
      required this.sourceUrl,
      required this.questions,
      required this.isFreePreview});
  final String id, title, duration, sourceUrl;
  final List<String> objectives;
  final List<Question> questions;
  final bool isFreePreview;
  String get sourceLabel => 'YouTube search: $title';
}

class LearningUnit {
  const LearningUnit(
      {required this.id,
      required this.title,
      required this.subject,
      required this.summary,
      required this.body,
      required this.objectives,
      required this.videos});
  final String id, title, subject, summary, body;
  final List<String> objectives;
  final List<VideoLesson> videos;
  String get duration => videos.first.duration;
  List<Question> get questions => videos.first.questions;
  bool get isFreePreview => videos.any((v) => v.isFreePreview);
}

class Subject {
  const Subject(this.name, this.shortName, this.icon, this.color, this.units);
  final String name, shortName;
  final IconData icon;
  final Color color;
  final List<LearningUnit> units;
}

const _topics = <String, List<String>>{
  'Engineering Mathematics': [
    'Matrices and determinants',
    'Differential calculus',
    'Integral calculus',
    'Differential equations'
  ],
  'Statistics & Analytics': [
    'Data classification',
    'Measures of central tendency',
    'Dispersion',
    'Probability basics'
  ],
  'IT Skills': [
    'Computer fundamentals',
    'Networks and internet',
    'Cyber safety',
    'Office productivity'
  ],
  'Fundamentals of Electrical & Electronics Engineering (FEEE)': [
    "Ohm's law and DC circuits",
    'AC fundamentals',
    'Semiconductor devices',
    'Digital electronics'
  ],
  'Project Management Skills': [
    'Project life cycle',
    'Planning and scheduling',
    'Cost and quality',
    'Risk management'
  ],
};

const _seedConcepts = <String, List<String>>{
  'Matrices and determinants': [
    'For a 2 by 2 matrix, determinant equals ad minus bc.',
    'An inverse exists only when the determinant is non zero.',
    'Matrix order is written as rows by columns.',
    'Interchanging two rows changes the determinant sign.'
  ],
  'Differential calculus': [
    'The derivative of x power n is n times x power n minus 1.',
    'The derivative of a constant is zero.',
    'A derivative represents instantaneous rate of change.',
    'At a stationary point the first derivative is zero.'
  ],
  'Integral calculus': [
    'Integration is the reverse operation of differentiation.',
    'An indefinite integral includes a constant of integration.',
    'The integral of x power n is x power n plus 1 divided by n plus 1.',
    'A definite integral evaluates accumulation between limits.'
  ],
  'Differential equations': [
    'Order is determined by the highest derivative present.',
    'A separable equation can be rearranged into x and y parts.',
    'A proposed solution is checked by substitution.',
    'The complementary solution belongs to the homogeneous equation.'
  ],
  'Data classification': [
    'Categorical data describes groups or labels.',
    'Discrete numerical data is countable.',
    'Continuous data can take values across an interval.',
    'Ordinal categories have a meaningful order.'
  ],
  'Measures of central tendency': [
    'Mean equals total of observations divided by their count.',
    'Median is the middle ordered observation.',
    'Mode is the most frequent observation.',
    'Median is resistant to extreme values compared with mean.'
  ],
  'Dispersion': [
    'Range equals maximum minus minimum.',
    'Variance averages squared deviations from the mean.',
    'Standard deviation is the square root of variance.',
    'Lower standard deviation indicates tighter clustering.'
  ],
  'Probability basics': [
    'Probability lies from zero to one inclusive.',
    'An event and its complement have probabilities totaling one.',
    'Independent events multiply for their joint probability.',
    'Mutually exclusive events cannot occur together.'
  ],
  'Computer fundamentals': [
    'The CPU fetches and executes instructions.',
    'RAM is volatile working memory.',
    'Persistent storage retains data without power.',
    'An operating system manages hardware and applications.'
  ],
  'Networks and internet': [
    'A router forwards packets between networks.',
    'An IP address identifies a network interface.',
    'HTTPS uses TLS to protect web traffic.',
    'DNS translates domain names into IP addresses.'
  ],
  'Cyber safety': [
    'Multi factor authentication adds protection beyond a password.',
    'Phishing often uses false urgency and imitation links.',
    'Software updates patch known vulnerabilities.',
    'Unique passwords limit damage from credential reuse.'
  ],
  'Office productivity': [
    'Spreadsheet formulas normally begin with an equals sign.',
    'Document styles provide consistent structure.',
    'Data validation restricts invalid spreadsheet input.',
    'A relative cell reference changes when copied.'
  ],
  "Ohm's law and DC circuits": [
    'Ohm law is V equals I times R.',
    'Series resistances add directly.',
    'Parallel branches share the same voltage.',
    'Electrical power equals voltage times current.'
  ],
  'AC fundamentals': [
    'Frequency is measured in hertz.',
    'RMS represents equivalent heating effect.',
    'One cycle spans 360 electrical degrees.',
    'An alternating waveform changes direction periodically.'
  ],
  'Semiconductor devices': [
    'A diode conducts mainly under forward bias.',
    'A transistor can operate as a switch or amplifier.',
    'An LED emits light under forward bias.',
    'A rectifier converts alternating input into unidirectional output.'
  ],
  'Digital electronics': [
    'AND is high only when every input is high.',
    'OR is low only when every input is low.',
    'NOT inverts its single input.',
    'A truth table lists output for every input combination.'
  ],
  'Project life cycle': [
    'Initiation establishes need and feasibility.',
    'Planning defines scope, schedule, cost and risk responses.',
    'Execution produces project deliverables.',
    'Closure records acceptance and lessons learned.'
  ],
  'Planning and scheduling': [
    'The critical path determines minimum project duration.',
    'A milestone normally has zero duration.',
    'A dependency constrains activity sequence.',
    'Float is the delay possible without delaying a target date.'
  ],
  'Cost and quality': [
    'A cost baseline supports planned versus actual comparison.',
    'Acceptance criteria define required deliverable conditions.',
    'Quality control checks outputs against criteria.',
    'Cost variance compares earned value with actual cost.'
  ],
  'Risk management': [
    'Risk exposure considers probability and impact.',
    'A risk owner monitors triggers and responses.',
    'Mitigation reduces probability or impact.',
    'A contingency response is used if the risk occurs.'
  ],
};

// Sixteen reviewed concepts extend the four foundation concepts above.  The
// resulting twenty concepts are partitioned (never recycled) across a topic's
// five lesson focuses.
const _additionalConcepts = <String, List<String>>{
  'Matrices and determinants': [
    'Matrix addition requires equal orders.',
    'Matrix multiplication requires the first column count to equal the second row count.',
    'The product AB need not equal BA.',
    'An identity matrix leaves a compatible matrix unchanged.',
    'A zero row makes a determinant zero.',
    'A triangular matrix determinant is the product of its diagonal entries.',
    'Equal rows make a determinant zero.',
    'Multiplying one row by k multiplies the determinant by k.',
    'A cofactor includes the sign factor minus one power row plus column.',
    'The adjugate is the transpose of the cofactor matrix.',
    'A singular matrix has determinant zero.',
    'A system has a unique solution when its coefficient determinant is non zero.',
    'The transpose swaps rows and columns.',
    'The transpose of a product AB is B transpose times A transpose.',
    'Elementary row replacement preserves a determinant.',
    'Cramer rule replaces one coefficient column with the constants.'
  ],
  'Differential calculus': [
    'The derivative of sin x is cos x.',
    'The derivative of cos x is minus sin x.',
    'The product rule differentiates uv as u prime v plus uv prime.',
    'The quotient rule has denominator v squared.',
    'The chain rule multiplies by the derivative of the inner function.',
    'A tangent slope equals the derivative at the contact point.',
    'A normal slope is the negative reciprocal of a non zero tangent slope.',
    'A positive derivative indicates local increase.',
    'A negative derivative indicates local decrease.',
    'A sign change from positive to negative identifies a local maximum.',
    'A sign change from negative to positive identifies a local minimum.',
    'The second derivative measures how the slope changes.',
    'A positive second derivative indicates concave up behaviour.',
    'Differentiability at a point implies continuity there.',
    'The derivative of e power x is e power x.',
    'The derivative of ln x is one divided by x for positive x.'
  ],
  'Integral calculus': [
    'The integral of one divided by x is ln absolute x plus C.',
    'The integral of e power x is e power x plus C.',
    'The integral of sin x is minus cos x plus C.',
    'The integral of cos x is sin x plus C.',
    'Substitution reverses the chain rule.',
    'Integration by parts is integral u dv equals uv minus integral v du.',
    'A constant multiplier may be taken outside an integral.',
    'Integrals distribute over sums.',
    'Reversing definite integral limits changes the sign.',
    'Equal definite integral limits give zero.',
    'Definite integrals are additive across an intermediate limit.',
    'Area below the axis contributes negative signed area.',
    'Total geometric area uses absolute contributions.',
    'The fundamental theorem links an accumulation derivative to its integrand.',
    'An antiderivative can be checked by differentiation.',
    'Simpson style numerical rules approximate an integral from sampled values.'
  ],
  'Differential equations': [
    'Degree is the power of the highest derivative after radicals and fractions are cleared.',
    'A first order linear equation has form dy/dx plus Py equals Q.',
    'The integrating factor for dy/dx plus Py equals Q is e power integral P dx.',
    'A general solution contains arbitrary constants.',
    'A particular solution satisfies supplied initial or boundary conditions.',
    'The number of arbitrary constants normally matches the equation order.',
    'A homogeneous first order equation can use substitution y equals vx.',
    'Exact equations satisfy partial M by partial y equals partial N by partial x.',
    'The solution of dy/dx equals ky is exponential.',
    'A zero forcing term makes a linear equation homogeneous.',
    'Superposition applies to linear homogeneous differential equations.',
    'Constant coefficients lead to an auxiliary equation.',
    'Distinct real auxiliary roots produce separate exponential terms.',
    'A repeated auxiliary root introduces an x multiplier.',
    'Complex auxiliary roots produce sine and cosine terms.',
    'Initial conditions determine constants after integration.'
  ],
  'Data classification': [
    'Nominal categories have no inherent ranking.',
    'Binary data has two possible categories.',
    'Primary data is collected directly for the current study.',
    'Secondary data was collected previously for another purpose.',
    'A population contains every unit of interest.',
    'A sample is a subset selected from a population.',
    'A census observes every population unit.',
    'A parameter describes a population.',
    'A statistic describes a sample.',
    'An identifier is not automatically a quantitative measurement.',
    'Interval scales have equal differences but no true zero.',
    'Ratio scales have equal differences and a meaningful zero.',
    'Cross sectional data observes units at one period.',
    'Time series data records a variable across time.',
    'Missing values must be identified before analysis.',
    'A representative sample reduces selection bias.'
  ],
  'Measures of central tendency': [
    'For an odd count, the median is the central ordered value.',
    'For an even count, the median averages the two central ordered values.',
    'A data set may have more than one mode.',
    'A data set may have no mode.',
    'A weighted mean uses weights in both numerator and denominator.',
    'The combined mean uses group sizes as weights.',
    'Adding a constant to every value adds it to the mean.',
    'Multiplying every value by k multiplies the mean by k.',
    'The geometric mean suits multiplicative growth rates.',
    'The harmonic mean suits rates over equal distances.',
    'The midrange averages the minimum and maximum.',
    'The mean uses every observation.',
    'The median depends on order rather than every magnitude.',
    'An extreme high value pulls the mean upward.',
    'For symmetric unimodal data, mean median and mode coincide.',
    'Grouped data means use class midpoints as representative values.'
  ],
  'Dispersion': [
    'Interquartile range equals the third quartile minus the first quartile.',
    'Quartile deviation is half the interquartile range.',
    'Mean absolute deviation uses absolute distances from a centre.',
    'Squared deviations are never negative.',
    'Population variance divides by population size.',
    'Sample variance commonly divides by n minus one.',
    'Variance is measured in squared units.',
    'Standard deviation uses the original measurement unit.',
    'Coefficient of variation compares relative spread using standard deviation divided by mean.',
    'Adding a constant to every observation leaves variance unchanged.',
    'Multiplying all observations by k multiplies standard deviation by absolute k.',
    'A zero standard deviation means all observations are identical.',
    'An outlier can strongly increase range and standard deviation.',
    'Interquartile range is resistant to extreme values.',
    'A box plot displays quartiles and potential outliers.',
    'Greater dispersion means observations are less tightly clustered.'
  ],
  'Probability basics': [
    'The sample space contains all possible outcomes.',
    'An impossible event has probability zero.',
    'A certain event has probability one.',
    'For equally likely outcomes probability is favourable count divided by total count.',
    'The addition rule subtracts the intersection to avoid double counting.',
    'Conditional probability restricts the sample space to the given event.',
    'P of A given B equals P of A intersection B divided by P of B.',
    'Independence means conditioning does not change an event probability.',
    'Mutually exclusive non impossible events are not independent.',
    'A random variable assigns numbers to outcomes.',
    'Expected value is a probability weighted average.',
    'A fair die gives each face probability one sixth.',
    'Sampling without replacement generally creates dependence.',
    'A tree diagram represents sequential outcomes.',
    'Bayes rule reverses a conditional probability using prior information.',
    'Probabilities over all disjoint exhaustive outcomes sum to one.'
  ],
  'Computer fundamentals': [
    'A bit is a binary digit.',
    'Eight bits form one byte.',
    'Input devices send data into a computer.',
    'Output devices present processed information.',
    'Cache is faster and smaller than main memory.',
    'ROM is non volatile memory.',
    'A file extension commonly indicates a file format.',
    'A folder organises files hierarchically.',
    'An application performs user oriented tasks.',
    'A device driver lets an operating system communicate with hardware.',
    'Booting loads the operating system for use.',
    'A process is a running program instance.',
    'Multitasking shares processor time among processes.',
    'Compression reduces the storage needed for data.',
    'A backup is a separate recoverable copy of data.',
    'Binary place values are powers of two.'
  ],
  'Networks and internet': [
    'A switch forwards frames within a local network.',
    'A modem converts signals for an access link.',
    'A LAN covers a limited local area.',
    'A WAN connects networks across large distances.',
    'A MAC address identifies a network interface at the data link layer.',
    'TCP provides ordered reliable delivery.',
    'UDP avoids connection setup and has lower overhead.',
    'HTTP transfers web resources.',
    'A URL identifies the location of a resource.',
    'A browser requests and renders web content.',
    'Upload sends data from a local device to a remote system.',
    'Download receives remote data onto a local device.',
    'Bandwidth is a link data rate capacity.',
    'Latency is the delay experienced by data.',
    'A firewall filters network traffic using rules.',
    'A private IP address is used inside local networks.'
  ],
  'Cyber safety': [
    'A passphrase can be both long and memorable.',
    'A password manager stores unique credentials securely.',
    'A one time password should never be shared.',
    'Ransomware encrypts or blocks data to demand payment.',
    'Malware is software designed to cause harm or misuse.',
    'Social engineering manipulates people rather than only technology.',
    'A suspicious attachment should be verified before opening.',
    'The visible link text may differ from its actual destination.',
    'Public Wi Fi does not guarantee private traffic.',
    'Device locking protects an unattended signed in session.',
    'Least privilege grants only access needed for a task.',
    'Regular backups support recovery after data loss.',
    'Antivirus detection does not replace safe behaviour.',
    'Personal information should be shared only with a justified recipient.',
    'A security incident should be reported promptly.',
    'HTTPS protects transport but does not prove every site is trustworthy.'
  ],
  'Office productivity': [
    'An absolute cell reference keeps both row and column fixed when copied.',
    'A mixed reference fixes either a row or a column.',
    'SUM adds values in a selected range.',
    'AVERAGE returns arithmetic mean for selected numeric cells.',
    'IF chooses a result based on a condition.',
    'Sorting rearranges rows using selected keys.',
    'Filtering hides rows that do not meet criteria.',
    'A chart should match the comparison or trend being communicated.',
    'A slide title should state the key idea clearly.',
    'A presentation theme keeps fonts and colours consistent.',
    'Track Changes records document edits for review.',
    'Comments support review without changing body text.',
    'Mail merge combines a template with recipient data.',
    'Headers and footers repeat document information.',
    'Cloud co authoring needs suitable sharing permissions.',
    'Exporting to PDF helps preserve document layout.'
  ],
  "Ohm's law and DC circuits": [
    'Current is charge flow per unit time.',
    'Voltage is electrical potential difference.',
    'Resistance opposes current flow.',
    'Current is the same through series components.',
    'Total current is the sum of parallel branch currents.',
    'Kirchhoff current law conserves charge at a junction.',
    'Kirchhoff voltage law makes the algebraic loop voltage sum zero.',
    'An open circuit ideally carries zero current.',
    'A short circuit has very low resistance.',
    'Electrical energy equals power multiplied by time.',
    'Resistors in parallel have an equivalent resistance below the smallest branch.',
    'Two equal parallel resistors have half either resistance.',
    'A voltage divider output depends on the resistance ratio.',
    'An ammeter is connected in series.',
    'A voltmeter is connected in parallel.',
    'A fuse opens a circuit when excessive current heats it.'
  ],
  'AC fundamentals': [
    'Peak value is the maximum instantaneous magnitude.',
    'For a sine wave RMS voltage equals peak voltage divided by square root two.',
    'Angular frequency equals two pi times frequency.',
    'Phase difference measures relative waveform displacement.',
    'Pure resistance has voltage and current in phase.',
    'Pure inductance has current lagging voltage by 90 degrees.',
    'Pure capacitance has current leading voltage by 90 degrees.',
    'Inductive reactance equals two pi f L.',
    'Capacitive reactance equals one divided by two pi f C.',
    'Impedance combines resistance and reactance.',
    'Power factor equals cosine of the phase angle.',
    'Real power equals RMS voltage times RMS current times power factor.',
    'A transformer requires changing magnetic flux.',
    'A step down transformer reduces secondary voltage.',
    'The mains waveform is approximately sinusoidal.',
    'Average power in a pure reactive element is zero.'
  ],
  'Semiconductor devices': [
    'Intrinsic semiconductor material is chemically pure.',
    'Doping changes semiconductor carrier concentration.',
    'N type material has electrons as majority carriers.',
    'P type material has holes as majority carriers.',
    'A PN junction forms a depletion region.',
    'Reverse bias widens the depletion region.',
    'A Zener diode is designed for controlled reverse breakdown.',
    'A rectifier diode should withstand reverse voltage.',
    'A half wave rectifier uses one half of an AC cycle.',
    'A full wave rectifier uses both AC half cycles.',
    'A filter capacitor reduces rectifier output ripple.',
    'A bipolar transistor has emitter base and collector terminals.',
    'A small base drive can control collector current in switching.',
    'Cutoff represents an off transistor state.',
    'Saturation represents an on switching state.',
    'LED series resistance limits forward current.'
  ],
  'Digital electronics': [
    'NAND is the complement of AND.',
    'NOR is the complement of OR.',
    'XOR is high when its two inputs differ.',
    'XNOR is high when its two inputs are equal.',
    'NAND alone can implement any Boolean function.',
    'NOR alone can implement any Boolean function.',
    'Boolean addition represents OR.',
    'Boolean multiplication represents AND.',
    'A plus zero equals A in Boolean algebra.',
    'A times one equals A in Boolean algebra.',
    'A plus its complement equals one.',
    'A times its complement equals zero.',
    'De Morgan changes complemented AND into OR of complements.',
    'A half adder produces sum and carry from two bits.',
    'A flip flop stores one binary bit.',
    'A binary counter advances through a defined state sequence.'
  ],
  'Project life cycle': [
    'A business case explains expected value and justification.',
    'A project charter formally authorises the project.',
    'Stakeholder identification begins during initiation.',
    'Scope describes included deliverables and boundaries.',
    'A work breakdown structure decomposes deliverables into manageable work.',
    'Requirements state stakeholder needs and constraints.',
    'A baseline is an approved reference for comparison.',
    'Monitoring compares actual performance with the plan.',
    'Change control evaluates proposed baseline changes.',
    'Corrective action addresses a detected performance variance.',
    'A deliverable is a verifiable project output.',
    'Phase gates support continue change or stop decisions.',
    'Sponsor support provides authority and direction.',
    'Handover transfers an accepted output to operations or users.',
    'Closure confirms contracts and records are completed.',
    'Lessons learned should be captured throughout and consolidated at closure.'
  ],
  'Planning and scheduling': [
    'An activity consumes time and possibly resources.',
    'A predecessor must occur before a dependent successor.',
    'Finish to start is a common dependency relationship.',
    'A network diagram shows activity dependencies.',
    'Forward pass calculates earliest start and finish times.',
    'Backward pass calculates latest start and finish times.',
    'Total float equals latest start minus earliest start.',
    'Critical activities normally have zero total float.',
    'Crashing shortens duration by adding cost or resources.',
    'Fast tracking overlaps work that was previously sequential.',
    'Resource levelling may extend the project schedule.',
    'A Gantt chart displays activities against calendar time.',
    'Duration is not the same as work effort.',
    'Lead permits a successor to start earlier.',
    'Lag inserts waiting time between linked activities.',
    'Schedule variance signals difference from planned progress.'
  ],
  'Cost and quality': [
    'A budget aggregates approved cost estimates.',
    'Direct costs can be attributed to specific project work.',
    'Indirect costs support work but are not tied to one activity.',
    'Contingency reserve covers identified uncertainty.',
    'Management reserve covers unknown unknown uncertainty.',
    'Planned value is budgeted cost for scheduled work.',
    'Earned value is budgeted cost for completed work.',
    'Actual cost is cost incurred for completed work.',
    'A negative cost variance means spending exceeds earned value.',
    'Cost performance index equals earned value divided by actual cost.',
    'Quality assurance improves the processes used to create outputs.',
    'Prevention aims to stop defects before they occur.',
    'Inspection detects whether an output meets requirements.',
    'A checklist promotes consistent verification.',
    'The cost of quality includes prevention appraisal and failure costs.',
    'Continuous improvement uses evidence to refine processes.'
  ],
  'Risk management': [
    'A threat may harm objectives while an opportunity may help them.',
    'A risk register records risks owners analysis and responses.',
    'A risk trigger indicates that a risk may be occurring.',
    'Avoidance removes the threat cause or changes the plan.',
    'Transfer shifts financial impact or ownership to a third party.',
    'Acceptance acknowledges a risk without proactive change.',
    'Exploit seeks to ensure an opportunity occurs.',
    'Residual risk remains after a response is implemented.',
    'Secondary risk arises because of a risk response.',
    'Qualitative analysis prioritises risks using relative scales.',
    'Quantitative analysis estimates numerical effect on objectives.',
    'Expected monetary value multiplies probability by financial impact.',
    'A contingency reserve supports planned risk responses.',
    'Issue management handles events that have already occurred.',
    'Regular risk reviews detect changes and new risks.',
    'Escalation moves a risk beyond team authority to the proper level.'
  ],
};

List<String> _allConcepts(String topic) => <String>[
      ..._seedConcepts[topic]!,
      ..._additionalConcepts[topic]!,
    ];

List<String> knowledgeForTopic(String topic) =>
    List<String>.unmodifiable(_allConcepts(topic));

const _lessonFocuses = <String>[
  'Concept foundations',
  'Worked examples and methods',
  'Applications and interpretation',
  'Common errors and diagnosis',
  'DCET exam revision practice',
];

String _plausibleMisstatement(String statement, int variant) {
  const substitutions = <(String, String)>[
    ('non zero', 'zero'),
    ('zero', 'one'),
    ('positive', 'negative'),
    ('negative', 'positive'),
    ('maximum', 'minimum'),
    ('minimum', 'maximum'),
    ('adds', 'subtracts'),
    ('add', 'subtract'),
    ('sum', 'difference'),
    ('product', 'sum'),
    ('divided by', 'multiplied by'),
    ('multiply', 'add'),
    ('squared', 'unchanged'),
    ('square root', 'square'),
    ('rows', 'columns only'),
    ('row', 'column'),
    ('series', 'parallel'),
    ('parallel', 'series'),
    ('current', 'voltage'),
    ('voltage', 'current'),
    ('forward', 'reverse'),
    ('reverse', 'forward'),
    ('high', 'low'),
    ('low', 'high'),
    ('before', 'after'),
    ('earliest', 'latest'),
    ('latest', 'earliest'),
    ('probability', 'duration'),
    ('mean', 'mode'),
    ('median', 'mean'),
    ('sample', 'population'),
    ('population', 'sample'),
    ('reliable', 'unordered'),
    ('volatile', 'permanent'),
    ('increases', 'decreases'),
    ('increase', 'decrease'),
    ('reduces', 'increases'),
    ('equal', 'unrelated'),
    ('same', 'different'),
    ('only', 'never'),
    ('all', 'none'),
    ('one', 'two'),
    ('two', 'one'),
  ];
  final start = variant % substitutions.length;
  for (var offset = 0; offset < substitutions.length; offset++) {
    final pair = substitutions[(start + offset) % substitutions.length];
    final index = statement.toLowerCase().indexOf(pair.$1);
    if (index >= 0) {
      return statement.replaceRange(index, index + pair.$1.length, pair.$2);
    }
  }
  final trimmed = statement.replaceFirst(RegExp(r'\.$'), '');
  return switch (variant % 3) {
    0 => '$trimmed without checking any required input or condition.',
    1 => '$trimmed only after swapping the stated cause and result.',
    _ => '$trimmed, and its measured value is always one.',
  };
}

LessonSpec _lessonSpec(String topic, int lessonIndex) {
  final focus = _lessonFocuses[lessonIndex];
  final topicConcepts = _allConcepts(topic);
  assert(
      topicConcepts.length == 20, '$topic must have exactly 20 authored seeds');
  final concepts = topicConcepts.sublist(lessonIndex * 4, lessonIndex * 4 + 4);
  final scenarios = <String>[
    'A learner is preparing a definition card',
    'A worked DCET solution must choose its next operation',
    'A technician or analyst must apply the rule to a practical case',
    'A classmate has written an incorrect revision note',
    'A final exam check is being performed under time pressure',
  ];
  return LessonSpec(
    id: '${topic.toLowerCase().replaceAll(RegExp(r'[^a z0 9]+'), ' ')} ${lessonIndex + 1}',
    title: focus,
    objectives: <String>[
      'Explain $topic using $focus',
      'Apply $topic to a concrete DCET case',
      'Diagnose a common $topic error',
    ],
    seeds: List<QuestionSeed>.generate(4, (seedIndex) {
      final concept = concepts[seedIndex];
      final globalIndex = lessonIndex * 4 + seedIndex;
      final distractors = <String>[
        _plausibleMisstatement(
            topicConcepts[(globalIndex + 1) % topicConcepts.length],
            globalIndex),
        _plausibleMisstatement(
            topicConcepts[(globalIndex + 7) % topicConcepts.length],
            globalIndex + 1),
        _plausibleMisstatement(
            topicConcepts[(globalIndex + 13) % topicConcepts.length],
            globalIndex + 2),
      ];
      return QuestionSeed(
        id: 'f${lessonIndex + 1} s${seedIndex + 1}',
        conceptId:
            '${topic.toLowerCase().replaceAll(RegExp(r'[^a z0 9]+'), ' ')} c${globalIndex + 1}',
        concept: concept,
        misconception: _plausibleMisstatement(concept, globalIndex + 3),
        scenario:
            '${scenarios[lessonIndex]} for $topic. The decision concerns: ${concept.replaceFirst(RegExp(r'\.$'), '')}',
        distractors: distractors,
      );
    }),
  );
}

const _modes = <String>[
  'concept',
  'outcome',
  'application',
  'diagnosis',
  'interpretation'
];

(String, String, List<String>, String)? _calculation(
    String topic, int variant) {
  final n = variant + 2;
  return switch (topic) {
    'Matrices and determinants' => (
        'For matrix [[$n,1],[2,${n + 1}]], find the determinant.',
        '${n * (n + 1) - 2}',
        ['${n * (n + 1) + 2}', '${n * (n + 1)}', '${2 - n * (n + 1)}'],
        'Using ad bc gives $n x ${n + 1} - 1 x 2 = ${n * (n + 1) - 2}.'
      ),
    'Differential calculus' => (
        'For y=x^$n, find dy/dx at x=1.',
        '$n',
        ['${n - 1}', '${n + 1}', '1'],
        'The power rule gives ${n}x^${n - 1}; at x=1 the value is $n.'
      ),
    'Integral calculus' => (
        'Evaluate the integral of x from 0 to ${2 * n}.',
        '${2 * n * n}',
        ['${4 * n * n}', '$n', '${2 * n}'],
        'The antiderivative is x squared over 2, giving ${2 * n * n}.'
      ),
    'Differential equations' => (
        'If dy/dx=$n and y(0)=1, find y(2).',
        '${2 * n + 1}',
        ['$n', '${2 * n}', '${n + 1}'],
        'Integration gives y=${n}x+C and the condition gives C=1.'
      ),
    'Measures of central tendency' => (
        'Find the mean of $n, ${n + 2}, ${n + 4}.',
        '${n + 2}',
        ['$n', '${n + 4}', '${3 * n + 6}'],
        'Their sum is ${3 * n + 6}; division by 3 gives ${n + 2}.'
      ),
    'Dispersion' => (
        'Find the range of $n, ${n + 3}, ${n + 8}.',
        '8',
        ['${n + 8}', '${n + 6}', '3'],
        'Range is maximum minus minimum: ${n + 8}   $n = 8.'
      ),
    'Probability basics' => (
        'A bag has $n red and $n blue counters. Find P(red).',
        '1/2',
        ['1/$n', '1', '0'],
        'There are $n favourable outcomes among ${2 * n} equally likely counters, so the probability is 1/2.'
      ),
    "Ohm's law and DC circuits" => (
        'A ${n * 4} V supply is across a $n ohm resistor. Find current.',
        '4 A',
        ['${n * n * 4} A', '$n A', '0.25 A'],
        'Ohm law gives I=V/R=${n * 4}/$n=4 A.'
      ),
    'AC fundamentals' => (
        'Find the period of a ${n * 10} Hz waveform.',
        '${(1 / (n * 10)).toStringAsFixed(3)} s',
        [
          '${n * 10} s',
          '${(1 / n).toStringAsFixed(3)} s',
          '${(10 / n).toStringAsFixed(3)} s'
        ],
        'Period is the reciprocal of frequency: T=1/${n * 10} s.'
      ),
    'Semiconductor devices' => (
        'A ${n + 2} V source drives a 2 V LED through ${n * 100} ohm. Find current.',
        '0.01 A',
        ['1 A', '0.1 A', '0.001 A'],
        'The resistor voltage is $n V, so I=$n/${n * 100}=0.01 A.'
      ),
    'Digital electronics' => (
        'What is AND output for inputs 1 and ${variant.isEven ? 0 : 1}?',
        variant.isEven ? '0' : '1',
        variant.isEven ? ['1', '10', 'Undefined'] : ['0', '10', 'Undefined'],
        'AND is high only when both inputs are high.'
      ),
    _ => null,
  };
}

List<String> _sameTopicOptions(List<QuestionSeed> seeds, int seedIndex,
    String correct, String misconception) {
  return <String>[correct, ...seeds[seedIndex].distractors];
}

List<Question> _assignment(
  String subject,
  String topic,
  LessonSpec spec,
) {
  return List<Question>.generate(20, (index) {
    final seedIndex = index % spec.seeds.length;
    final modeIndex = index ~/ spec.seeds.length;
    final seed = spec.seeds[seedIndex];
    final mode = _modes[modeIndex];
    final modePrompt = switch (mode) {
      'concept' => 'In $topic, what is the accurate concept for ${seed.id}?',
      'outcome' => '${seed.scenario}. Which outcome or rule is valid?',
      'application' =>
        '${seed.scenario}. Which principle should be applied to this specific case?',
      'diagnosis' =>
        'A learner says: "${seed.misconception}" What correction should be made?',
      _ =>
        '${seed.scenario}. Which conclusion correctly interprets this result?',
    };
    final prompt = '${spec.title}   $modePrompt';
    final calculation = mode == 'outcome'
        ? _calculation(topic, seedIndex + spec.id.hashCode.abs() % 5)
        : null;
    if (calculation != null) {
      final answer = (seedIndex + modeIndex) % 4;
      final raw = <String>[calculation.$2, ...calculation.$3];
      final options = List<String>.filled(4, '');
      options[answer] = raw.first;
      var wrong = 1;
      for (var slot = 0; slot < 4; slot++) {
        if (slot != answer) options[slot] = raw[wrong++];
      }
      return Question(
        '${spec.title}   $topic calculation ${seedIndex + 1}: ${calculation.$1}',
        options,
        answer,
        '${spec.title} in $subject   $topic. ${calculation.$4}',
        semanticId: '${seed.conceptId}/$mode',
        conceptId: seed.conceptId,
      );
    }
    final raw = _sameTopicOptions(
        spec.seeds, seedIndex, seed.concept, seed.misconception);
    final answer = (seedIndex + modeIndex) % 4;
    final options = List<String>.filled(4, '');
    options[answer] = raw.first;
    var wrong = 1;
    for (var slot = 0; slot < 4; slot++) {
      if (slot != answer) options[slot] = raw[wrong++];
    }
    return Question(
      prompt,
      options,
      answer,
      'For ${spec.title} in $subject   $topic: ${seed.concept}',
      semanticId: '${seed.conceptId}/$mode',
      conceptId: seed.conceptId,
    );
  });
}

String _searchUrl(String subject, String topic, String focus) => Uri.https(
      'www.youtube.com',
      '/results',
      {'search_query': 'DCET $subject $topic $focus Kannada English'},
    ).toString();

class DemoRepository {
  late final List<Subject> subjects = [
    _subject('Engineering Mathematics', 'Mathematics', Icons.functions_rounded,
        const Color(0xFF6D4AA2), 0),
    _subject('Statistics & Analytics', 'Statistics', Icons.query_stats_rounded,
        const Color(0xFFCB6B51), 1),
    _subject('IT Skills', 'IT Skills', Icons.computer_rounded,
        const Color(0xFF2D8C6B), 2),
    _subject('Fundamentals of Electrical & Electronics Engineering (FEEE)',
        'FEEE', Icons.electric_bolt_rounded, const Color(0xFFD28C2B), 3),
    _subject('Project Management Skills', 'Project Mgmt.',
        Icons.account_tree_rounded, const Color(0xFF4776A8), 4),
  ];

  Subject _subject(
      String name, String short, IconData icon, Color color, int subjectIndex) {
    final slug = short.toLowerCase().replaceAll(RegExp('[^a z]'), '');
    final units = <LearningUnit>[];
    for (var topicIndex = 0; topicIndex < _topics[name]!.length; topicIndex++) {
      final topic = _topics[name]![topicIndex];
      units.add(LearningUnit(
        id: '$slug topic $topicIndex',
        title: topic,
        subject: name,
        summary: 'Build an exam ready foundation in $topic.',
        body:
            'This original revision guide introduces $topic, its central definitions, a reliable solution method, and a final result check. Compare the outline with the current official DCET notification.',
        objectives: const [
          'Recognise key terms and notation',
          'Apply the central rule to a simple problem',
          'Check the result using definitions and units'
        ],
        videos: List.generate(5, (videoIndex) {
          final spec = _lessonSpec(topic, videoIndex);
          return VideoLesson(
              id: '$slug $topicIndex video $videoIndex',
              title: spec.title,
              duration: '${10 + videoIndex * 3} min',
              objectives: spec.objectives,
              sourceUrl: _searchUrl(name, topic, spec.title),
              questions: _assignment(name, topic, spec),
              isFreePreview: topicIndex == 0 && videoIndex == 0);
        }),
      ));
    }
    return Subject(name, short, icon, color, units);
  }

  List<LearningUnit> get units => [for (final s in subjects) ...s.units];
  List<VideoLesson> get videos => [for (final u in units) ...u.videos];
  LearningUnit? byId(String id) {
    for (final u in units) {
      if (u.id == id) return u;
    }
    return null;
  }

  VideoLesson? videoById(String id) {
    for (final v in videos) {
      if (v.id == id) return v;
    }
    return null;
  }
}

enum LibraryKind { syllabus, previousPaper, modelPaper, notes, cutoff, update }

class LibraryItem {
  const LibraryItem(this.title, this.subtitle, this.kind,
      {this.year, this.source = 'DCET Master original reference'});
  final String title, subtitle, source;
  final LibraryKind kind;
  final int? year;
  bool get requiresSubscription => kind == LibraryKind.modelPaper;
}

const libraryItems = [
  LibraryItem(
      'Engineering Mathematics syllabus',
      'Matrices, calculus, integrals and differential equations',
      LibraryKind.syllabus),
  LibraryItem('Statistics & Analytics syllabus',
      'Data, averages, dispersion and probability', LibraryKind.syllabus),
  LibraryItem('IT Skills syllabus',
      'Computing, networks, safety and productivity', LibraryKind.syllabus),
  LibraryItem('FEEE syllabus',
      'Circuits, semiconductors and digital electronics', LibraryKind.syllabus),
  LibraryItem('Project Management syllabus', 'Planning, quality and risk',
      LibraryKind.syllabus),
  LibraryItem('2025 previous paper index', 'Verify availability on KEA',
      LibraryKind.previousPaper,
      year: 2025),
  LibraryItem(
      'Model paper 01', 'Original timed practice', LibraryKind.modelPaper),
  LibraryItem('Engineering Mathematics notes', 'Formula and method guide',
      LibraryKind.notes),
  LibraryItem('Statistics & Analytics notes', 'Interpretation guide',
      LibraryKind.notes),
  LibraryItem('IT Skills notes', 'Computing revision', LibraryKind.notes),
  LibraryItem('FEEE notes', 'Circuit revision', LibraryKind.notes),
  LibraryItem(
      'Project Management notes', 'Planning revision', LibraryKind.notes),
  LibraryItem(
      '2025 cutoff reference', 'Verify ranks on KEA', LibraryKind.cutoff,
      year: 2025),
  LibraryItem('KEA DCET portal', 'Official notifications', LibraryKind.update),
];
