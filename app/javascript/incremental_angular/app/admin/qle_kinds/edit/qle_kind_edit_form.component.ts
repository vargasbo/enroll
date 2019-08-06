import { Component, Injector, ElementRef, Inject, ViewChild } from '@angular/core';
import { QleKindEditResource } from './qle_kind_edit_data';
import { FormGroup, FormControl, FormBuilder, FormArray, AbstractControl, Validators } from '@angular/forms';
import { QleKindEditService } from '../qle_kind_services';
import { ErrorLocalizer } from '../../../error_localizer';
import { ErrorMapper, ErrorResponse } from '../../../error_mapper';
import { HttpResponse } from "@angular/common/http";
// import { DragDropModule } from '@angular/cdk/drag-drop';
// import {CdkDragDrop, moveItemInArray} from '@angular/cdk/drag-drop';



@Component({
  selector: 'admin-qle-kind-edit-form',
  templateUrl: './qle_kind_edit_form.component.html'
})
export class QleKindEditFormComponent {
  public qleKindToEdit : QleKindEditResource | null = null;
  public editUri : string | null = null;
  public editFormGroup : FormGroup = new FormGroup({});
  @ViewChild('headerRef') headerRef: ElementRef;
  public marketKindsList = new FormArray([])

  public effectiveOnOptionsArray =  [
    { name: 'Date of Event',  selected: false, id: 1 },
    { name: 'First of Next Month',  selected: false, id: 2 },
    { name: 'First of Month',  selected: false, id: 3 },
    { name: 'First Fixed of Next Month',  selected: false, id: 4 },
    { name: 'Next 15 of the month',  selected: false, id: 5 },
    { name: 'Exact Date',  selected: false, id: 6 },
    { name: 'Date options available',  selected: false, id: 7 }
  ]

  public actionKindList = [
    {name:"Not Applicable", code:"not_applicable"},
    {name:"Drop Member", code:"drop_member" }, 
    {name:"Adminstrative", code:"administrative" }, 
    {name:"Add Member", code: "add_member"},
    {name:"Add Benefit", code: "add_benefit" }, 
    {name:"Change Benefit", code:"change_benefit" }, 
    {name:"Transition Member", code:"transition_member" },
    {name:"Terminate Benefit", code:"terminate_benefit" }
  ]
  
  public reasonList = [
    {name:"Not Applicable", code: "not_applicable"},
    {name:"Natural Disaster", code: "exceptional_circumstances_natural_disaster"},
    {name:"Medical Emergency", code: "exceptional_circumstances_medical_emergency"},
    {name:"System Outage", code: "exceptional_circumstances_system_outage"},
    {name:"Domestic Abuse", code: "exceptional_circumstances_domestic_abuse"},
    {name:"Civic Service",code:"exceptional_circumstances_civic_service"},
    {name:"Exceptional Circumstances",code: "exceptional_circumstances"}  
  ]
  constructor(
    injector: Injector,
    @Inject("QleKindEditService") private editService : QleKindEditService,
    private errorLocalizer: ErrorLocalizer,
    private _editForm: FormBuilder,
    private _elementRef : ElementRef) {
     this.buildInitialForm(_editForm);

  }
  public getOptions(){
    return this.effectiveOnOptionsArray
  }
  private buildInitialForm(formBuilder : FormBuilder) {
    // var qControls = formBuilder.array([]);
    var submissionUriAttribute = (<HTMLElement>this._elementRef.nativeElement).getAttribute("data-qle-kind-edit-url");
    if (submissionUriAttribute != null) {
      this.editUri = submissionUriAttribute;
    }
      var marketKindsAttribute = (<HTMLElement>this._elementRef.nativeElement).getAttribute("data-qle-kind-market-kinds");
    if (marketKindsAttribute != null) {
      var marketKindsArrayJson = JSON.parse(marketKindsAttribute)
      this.marketKindsList = marketKindsArrayJson;
    }
    var qleKindToEditJson = (<HTMLElement>this._elementRef.nativeElement).getAttribute("data-qle-kind-to-edit");
    if (qleKindToEditJson != null) {
      this.qleKindToEdit = JSON.parse(qleKindToEditJson)
      if (this.qleKindToEdit != null){
        var formGroup = formBuilder.group({
          id: this.qleKindToEdit._id,
          title: ['', Validators.required],
          tool_tip: ['', [Validators.required, Validators.minLength(1)]],
          action_kind: ['',[]],
          reason: ['', [Validators.required, Validators.minLength(1)]],
          market_kind: [''],
          visible_to_customer: [''],
          is_self_attested: [''],
          effective_on_kinds:  new FormArray([]),
          pre_event_sep_in_days:[0, Validators.required],
          post_event_sep_in_days:[0, Validators.required],
          start_on: [''],   
          end_on: ['']
        })
        this.editFormGroup = formGroup;
        this.addCheckboxes();
      }
    }
  }
  private addCheckboxes() {
    this.effectiveOnOptionsArray.map((o, i) => {
      const control = new FormControl( i === 0); // if first item set to true, else false
      (this.editFormGroup.controls.effective_on_kinds as FormArray).push(control);
    });
  }


  public hasErrors(control : AbstractControl) : Boolean {
    return ((control.touched || control.dirty) && !control.valid);
  }

  public errorClassFor(control : AbstractControl) : String {
    return (this.hasErrors(control) ? " has-error" : "");
  }

  ngOnInit() {
    // var qleKindToEditJson = (<HTMLElement>this._elementRef.nativeElement).getAttribute("data-qle-kind-to-edit");
    // if (qleKindToEditJson != null) {
    //   this.qleKindToEdit = JSON.parse(qleKindToEditJson)
    // console.log(this.qleKindToEdit)
    //   var formGroup = this._editForm.group({
    //     title: ['', Validators.required],
    //     tool_tip: ['', [Validators.required, Validators.minLength(1)]],
    //     action_kind: ['',[]],
    //     reason: ['', [Validators.required, Validators.minLength(1)]],
    //     market_kind: ['', [Validators.required, Validators.minLength(1)]],
    //     is_self_attested: [''],
    //     effective_on_options:  new FormArray([]),
    //     pre_event_sep_eligibility:[0, Validators.required],
    //     post_event_sep_eligibility:[0, Validators.required],
    //     available_in_system_from: [''],   
    //     available_in_system_until: ['']
    //   });
    //   }
    }

  // }

  hasResource() {
    // return this.qleKindToEdit != null;
  }

  submitEdit() {
    var form = this;
    var errorMapper = new ErrorMapper();
    if (this.editFormGroup != null) {
      console.log(this._elementRef.nativeElement.querySelector('select#qle_kind_edit_form_action_kind option:checked'))
      // this.editFormGroup.value.visible_to_customer = this._elementRef.nativeElement.querySelector('input#qle_kind_edit_form_visible_to_customer').value
      this.editFormGroup.value.action_kind = this._elementRef.nativeElement.querySelector('select#qle_kind_edit_form_action_kind option:checked').value
      this.editFormGroup.value.reason = this._elementRef.nativeElement.querySelector('select#qle_kind_edit_form_reason option:checked').value   
      if (this.editUri != null) {
        var invocation = this.editService.submitEdit(this.editUri, this.editFormGroup.value);
        invocation.subscribe(
          function(data: HttpResponse<any>) {
            var location_header = data.body.next_url;
            if (location_header != null) {
              // TODO: Can we add a div append here to show the success or decline message
              // or should we add a new function?
              window.location.href = location_header;
            }
          },
          function(error) {
            errorMapper.mapParentErrors(form.editFormGroup, <ErrorResponse>(error.error.errors));
            errorMapper.processErrors(form.editFormGroup, <ErrorResponse>(error.error.errors));
            form.headerRef.nativeElement.scrollIntoView();
          }
        )
      }
    } else {
        errorMapper.cascadeTouch(this.editFormGroup);
        errorMapper.invalidParentForm(this.editFormGroup);
    }
  }
}
