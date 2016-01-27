<?php
/**
 * @file
 * Enables modules and site configuration for a standard site installation.
 */

/**
 * Implements hook_form_FORM_ID_alter() for install_configure_form().
 *
 * Allows the profile to alter the site configuration form.
 */
function faktura_suite_form_install_configure_form_alter(&$form, $form_state) {
  // Pre-populate the site name with the server name.
  $form['site_information']['site_name']['#default_value'] = $_SERVER['SERVER_NAME'];

  $form['filesystem_settings'] = array(
    '#title' => st('Filesystem settings'),
    '#type' => 'fieldset',
  );
  $form['filesystem_settings']['file_private_path'] = array(
    '#type' => 'textfield',
    '#title' => st('Private file system path'),
    '#default_value' => variable_get('file_private_path', 'sites/default/files/private'),
    '#maxlength' => 255,
    '#required' => TRUE,
  );

  $form['#validate'][] = 'faktura_suite_file_private_path_validate';
  $form['#submit'][] = 'faktura_suite_file_private_path_submit';
}

function faktura_suite_file_private_path_validate($form, $form_state){
  $dir = $form_state['values']['file_private_path'];
  if(!file_prepare_directory($dir, FILE_CREATE_DIRECTORY)){
    if(is_dir($dir)){
      form_set_error('file_private_path', 'The private filesystem path is not writable. Drupal needs write permissions to ' . $dir);
    }else{
      form_set_error('file_private_path', 'The private filesystem folder does not exist and can not be created. Please set the permissions, or create the folder manually.');
    }
  }
}

function faktura_suite_file_private_path_submit($form, $form_state){
  variable_set('file_private_path', $form_state['values']['file_private_path']);
}

/** 
 * Add additional install tasks 
 */
function faktura_suite_install_tasks(){
  
  $tasks = array();
  
  $tasks['faktura_suite_company_form'] = array(
    'display_name' => st('Create company'),
    'display' => TRUE,
    'type' => 'form',
  );

  $tasks['faktura_suite_tax_form'] = array(
    'display_name' => st('Create tax'),
    'display' => TRUE,
    'type' => 'form',
  );
  
  return $tasks;
}

/**
 * Implements hook_install_tasks_alter().
 */
function faktura_suite_install_tasks_alter(&$tasks, $install_state) {
  $tasks['install_select_profile']['display'] = FALSE;
  $welcome['faktura_suite_welcome_message'] = array(
    'display_name' => st('Welcome'),
    'display' => TRUE,
    'type' => 'form',
    'run' => isset($install_state['parameters']['welcome']) ? INSTALL_TASK_SKIP : INSTALL_TASK_RUN_IF_REACHED,
  );
  $old_tasks = $tasks;
  $tasks = array_slice($old_tasks, 0, 1) + $welcome+ array_slice($old_tasks, 1);
}

function faktura_suite_welcome_message($form, $form_state){
  drupal_set_title(st('Welcome'));
  $welcome = st('<p>The following steps will guide you throuh the installation '
    . 'and configuration of your new Faktura-Site. This project is under active '
    . 'development so feel free to visit our '
    . l('homepage', 'http://www.kommune3.org')
    . ' for support or feature requests.</p>');
  $form = array();
  $form['welcome_message'] = array(
    '#markup' => $welcome);
  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => st('Install Faktura'),
  );
  return $form;
}

function faktura_suite_welcome_message_submit($form, &$form_state) {
  global $install_state;
  $install_state['parameters']['welcome'] = 'done';
}

/**
 * Installation task "Create company"
 * 
 */
function faktura_suite_company_form($form, &$form_state){
  drupal_set_title(st('Create company'));
  $form = array();
  
  $form['company'] = array(
    '#type' => 'textfield',
    '#title' => st('Company')
  );
  
  $form['street'] = array(
    '#type' => 'textfield',
    '#title' => st('Street')
  );
  
  $form['zip'] = array(
    '#type' => 'textfield',
    '#title' => st('ZIP code')
  );
  
  $form['city'] = array(
    '#type' => 'textfield',
    '#title' => st('City')
  );
  
  $form['submit'] = array(
    '#value' => st('Save and continue'),
    '#type' => 'submit',
  );
  
  return $form;
}

function faktura_suite_company_form_validate($form, $form_state){
  $values = $form_state['values'];
  
  // Todo: Perform validations tasks
}


function faktura_suite_company_form_submit($form, $form_state){
  
  module_load_include('inc', 'entity', 'includes/entity.controller');
  
  $values = $form_state['values'];
  global $user;
  $node_type = 'company';
  $node = (object) array(
    'uid' => $user->uid,
    'name' => (isset($user->name)) ? $user->name : '',
    'type' => $node_type,
    'language' => LANGUAGE_NONE,  
    'title' => $values['company'],
    'field_company' => array(
      LANGUAGE_NONE => array(
        0 => array(
          'value' => $values['company'],
          'format' => NULL,
          'save_value' => $values['company']
        ),
      ),
    ),
    'field_street' => array(
      LANGUAGE_NONE => array(
        0 => array('value' => $values['street'],),
      ),
    ),
    'field_zip' => array(
      LANGUAGE_NONE => array(
        0 => array('value' => $values['zip'],),
      ),
    ),
    'field_city' => array(
      LANGUAGE_NONE => array(
        0 => array('value' => $values['city'],),
      ),
    ),
  );
  node_object_prepare($node);   
  node_save($node);      
}


/**
 * Installation task "Create tax"
 * 
 */
function faktura_suite_tax_form($form, &$form_state){
  drupal_set_title(st('Create tax'));
  $form = array();
  
  $form['title'] = array(
    '#type' => 'textfield',
    '#title' => st('Tax title'),
    '#description' => st('The title of the tax (e. g. "VAT" or "MwSt.")'),
  );
  
  $form['tax_value'] = array(
    '#type' => 'textfield',
    '#title' => st('Value'),
    '#field_suffix' => '%',
    '#size' => 5
  );
  
  $form['submit'] = array(
    '#value' => st('Save and continue'),
    '#type' => 'submit',
  );
  
  return $form;
}

function faktura_suite_tax_form_validate($form, $form_state){
  $values = $form_state['values'];
  
  // Todo: Perform validations tasks
}

function faktura_suite_tax_form_submit($form, $form_state){
  
  module_load_include('inc', 'entity', 'includes/entity.controller');
  
  $values = $form_state['values'];
  global $user;
  $node = (object) array(
    'uid' => $user->uid,
    'name' => (isset($user->name)) ? $user->name : '',
    'type' => 'tax',
    'language' => LANGUAGE_NONE,  
    'title' => $values['title'],
    'field_tax_value' => array(
      LANGUAGE_NONE => array(
        0 => array('value' => $values['tax_value'],),
      ),
    ),
  );
  node_object_prepare($node);   
  node_save($node);      
}